import Foundation
import Combine
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var currentPlayer: Player?
    @Published var gameRoom: GameRoom?
    @Published var currentQuestion: Question?
    @Published var displayedText: String = ""
    @Published var shuffledAnswers: [String] = []
    @Published var timeRemaining: Double = 10.0
    @Published var selectedAnswer: String?
    @Published var hasAnswered: Bool = false
    @Published var showCorrectAnswer: Bool = false
    @Published var revealedAnswers: Set<String> = []
    @Published var revealedPlayers: [String: [String]] = [:] // answer -> [playerIDs] in reveal order
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var gamePhase: GamePhase = .menu
    @Published var selectedDifficulty: Question.Difficulty = .medium // kept for compatibility
    @Published var questionStartTime: TimeInterval = 0
    @Published var showScoreUpdates: Bool = false
    @Published var answersLocked: Bool = false
    
    // Flag to freeze timer updates during reveals
    private var isTimerFrozen: Bool = false
    
    // Store scores BEFORE this round for display purposes
    private var scoresBeforeRound: [String: Int] = [:]
    // Store NEW scores (after answering) to update during reveal
    private var pendingScores: [String: Int] = [:]
    private var hasTriggeredReveal: Bool = false
    private var lastObservedQuestionIndex: Int = -1
    private var lastObservedTimerEndTime: TimeInterval = 0
    private var isExpectingFreshTimer: Bool = false

    // Track questionStartTime for each round to prevent stale answer time calculations
    private var currentRoundId: Int = 0
    // Store answer times calculated locally to prevent sync issues
    private var localAnswerTimes: [String: Double] = [:]

    enum GamePhase {
        case menu
        case lobby
        case playing
        case roundEnd
        case gameOver
    }

    private var firebaseManager = FirebaseManager.shared
    private var gameLogic = GameLogicManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var typewriterTimer: Timer?
    private var checkTimer: Timer?

    init() {
        observeFirebaseRoom()
    }

    // MARK: - Room Management

    func createRoom(playerName: String, isSinglePlayer: Bool) {
        isLoading = true
        errorMessage = nil

        let defaultEmojis = ["🎬", "🍿", "🎭", "🎪", "🎨", "🎯", "🎸", "🎺", "🎻", "🎹"]
        let randomEmoji = defaultEmojis.randomElement() ?? "🎬"

        let player = Player(name: playerName, avatarEmoji: randomEmoji, isHost: true)
        currentPlayer = player

        firebaseManager.createRoom(hostPlayer: player, isSinglePlayer: isSinglePlayer, difficulty: .medium) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let room):
                    self?.gameRoom = room
                    self?.gamePhase = .lobby

                    // If single player, add AI bots
                    if isSinglePlayer {
                        self?.addAIBotsToRoom(roomCode: room.code)
                    }

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func joinRoom(code: String, playerName: String) {
        isLoading = true
        errorMessage = nil

        let avatarEmojis = ["🎬", "🍿", "🎭", "🎪", "🎨", "🎯", "🎸", "🎺", "🎻", "🎹"]
        let randomEmoji = avatarEmojis.randomElement() ?? "🎬"

        let player = Player(name: playerName, avatarEmoji: randomEmoji)
        currentPlayer = player

        firebaseManager.joinRoom(code: code.uppercased(), player: player) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let room):
                    self?.gameRoom = room
                    self?.gamePhase = .lobby
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func addAIBotsToRoom(roomCode: String) {
        let aiBots = gameLogic.generateAIPlayers(count: 3)

        for bot in aiBots {
            firebaseManager.addPlayer(bot, to: roomCode)
        }
    }

    func leaveRoom() {
        // Prevent multiple calls
        guard gamePhase != .menu else {
            print("🚪 Already in menu, ignoring duplicate leaveRoom call")
            return
        }

        guard let player = currentPlayer, let room = gameRoom else {
            // Even if no room, still cleanup
            print("🚪 No room/player found, performing cleanup")
            cleanup()
            return
        }

        print("🚪 Leaving room - Host: \(player.isHost), Room: \(room.code)")

        // Capture info before cleanup clears it
        let wasHost = player.isHost
        let roomCode = room.code
        let playerId = player.id

        // Cleanup local state first (sets gamePhase to .menu, preventing observer re-trigger)
        cleanup()

        // Then tell Firebase
        if wasHost {
            firebaseManager.deleteRoom(code: roomCode)
        } else {
            firebaseManager.leaveRoom(playerId: playerId, code: roomCode)
        }
    }

    // MARK: - Game Flow

    func startGame() {
        guard let room = gameRoom, let player = currentPlayer, player.isHost else { return }

        // Use a FIXED SEED for deterministic question order across all players
        let seed = room.code.hashValue
        print("🎮 HOST: Starting game with seed: \(seed)")

        gameLogic.currentQuestions = MovieQuotes.shared.getRandomQuestions(count: room.totalRounds, seed: seed)

        // Validate questions loaded
        guard gameLogic.currentQuestions.count >= room.totalRounds else {
            print("❌ HOST: Failed to load enough questions")
            errorMessage = "Failed to load questions"
            return
        }
        
        // Debug: Print first few question IDs
        print("🎮 HOST: Selected \(gameLogic.currentQuestions.count) questions")
        print("🎮 HOST: First 3 questions: \(gameLogic.currentQuestions.prefix(3).map { $0.id })")
        
        // Store question IDs in Firebase for non-hosts to use
        let questionIds = gameLogic.currentQuestions.map { $0.id }
        firebaseManager.storeQuestionIds(questionIds, for: room.code)
        
        gameLogic.currentQuestionIndex = 0
        firebaseManager.updateGameState(.playing, for: room.code)
        firebaseManager.updateCurrentRound(1, for: room.code)
        firebaseManager.updateCurrentQuestion(0, for: room.code)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startNewRound()
        }
    }

    private func startNewRound() {
        guard let room = gameRoom,
              let question = gameLogic.getCurrentQuestion() else { return }

        print("🎮 HOST: Starting round \(room.currentRound), question #\(gameLogic.currentQuestionIndex)")
        print("🎮 HOST: Question ID: \(question.id), Quote: \(question.quote.prefix(30))...")

        currentQuestion = question
        // Build answers array manually (don't use question.allAnswers as it's randomly shuffled)
        var answersToShuffle = question.wrongAnswers
        answersToShuffle.append(question.correctAnswer)
        // Use deterministic shuffle based on question ID
        shuffledAnswers = deterministicShuffle(array: answersToShuffle, seed: question.id.hashValue)
        
        print("🎮 HOST: Shuffled answers: \(shuffledAnswers)")
        
        displayedText = ""
        selectedAnswer = nil
        hasAnswered = false
        showCorrectAnswer = false
        revealedAnswers = []
        revealedPlayers = [:]
        showScoreUpdates = false
        answersLocked = false
        hasTriggeredReveal = false
        isTimerFrozen = false  // Unfreeze timer for new round
        gamePhase = .playing

        // Increment round ID for tracking stale data
        currentRoundId += 1

        // Clear local answer times for new round
        localAnswerTimes = [:]

        // Capture scores BEFORE this round
        scoresBeforeRound = [:]
        for (id, player) in room.players {
            scoresBeforeRound[id] = player.score
        }

        // Clear pending scores for new round
        pendingScores = [:]

        // Reset all players' answered status
        firebaseManager.resetPlayersAnswered(for: room.code)

        // Start typewriter animation
        startTypewriterAnimation(text: question.quote)

        // Start timer
        questionStartTime = Date().timeIntervalSince1970
        let endTime = questionStartTime + 10.0
        firebaseManager.updateTimer(endTime: endTime, for: room.code)
        
        print("🎮 HOST: Timer - startTime: \(questionStartTime), endTime: \(endTime)")

        gameLogic.startTimer(endTime: endTime, onTick: { [weak self] remaining in
            guard let self = self, !self.isTimerFrozen else { return }
            self.timeRemaining = remaining
        }, onComplete: { [weak self] in
            self?.handleTimerComplete()
        })
        
        // Start periodic check for all players answered
        startPeriodicCheck()

        // Schedule AI answers for single player (only host does this)
        if room.isSinglePlayer, currentPlayer?.isHost == true {
            let aiPlayers = Array(room.players.values.filter { $0.isAI })
            gameLogic.scheduleAIAnswers(aiPlayers: aiPlayers, roomCode: room.code,
                                       questionStartTime: questionStartTime,
                                       correctAnswer: question.correctAnswer,
                                       difficulty: room.difficulty) { [weak self] playerId, answerTime, answer in
                self?.handleAIAnswer(playerId: playerId, answer: answer, answerTime: answerTime)
            }
        }
    }
    
    // Deterministic shuffle using a seed
    private func deterministicShuffle<T>(array: [T], seed: Int) -> [T] {
        var rng = SeededRandomNumberGenerator(seed: seed)
        var shuffled = array
        for i in (1..<shuffled.count).reversed() {
            let j = Int(rng.next() % UInt64(i + 1))
            shuffled.swapAt(i, j)
        }
        return shuffled
    }
    
    private func startPeriodicCheck() {
        // Check every 0.3 seconds if all players have answered
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.checkIfAllPlayersAnswered()
        }
    }
    
    private func stopPeriodicCheck() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    func submitAnswer(_ answer: String) {
        // LOCK CHECK - Cannot answer if locked
        guard !answersLocked,
              !hasAnswered,
              let room = gameRoom,
              let player = currentPlayer,
              let question = currentQuestion else { return }

        hasAnswered = true
        selectedAnswer = answer

        let answerTime = Date().timeIntervalSince1970
        let isCorrect = gameLogic.isCorrectAnswer(selectedAnswer: answer, question: question)

        // Store the elapsed time locally for reliable display
        let elapsed = answerTime - questionStartTime
        if elapsed >= 0 && elapsed <= 10.0 {
            localAnswerTimes[player.id] = elapsed
        }

        var newScore = player.score
        if isCorrect {
            let points = gameLogic.calculateScore(answerTime: answerTime, questionStartTime: questionStartTime)
            newScore += points
        }

        // Store the new score in pendingScores (will be pushed to Firebase during reveal)
        pendingScores[player.id] = newScore

        // Update Firebase with answer info but WITHOUT score update (to prevent score leak)
        firebaseManager.updatePlayerAnswer(playerId: player.id, hasAnswered: true,
                                          answerTime: answerTime, selectedAnswer: answer, for: room.code)
    }

    private func handleAIAnswer(playerId: String, answer: String, answerTime: TimeInterval) {
        guard let room = gameRoom,
              let question = currentQuestion,
              let aiPlayer = room.players[playerId] else { return }

        let isCorrect = gameLogic.isCorrectAnswer(selectedAnswer: answer, question: question)

        // Store the elapsed time locally for reliable display
        let elapsed = answerTime - questionStartTime
        if elapsed >= 0 && elapsed <= 10.0 {
            localAnswerTimes[playerId] = elapsed
        }

        var newScore = aiPlayer.score
        if isCorrect {
            let points = gameLogic.calculateScore(answerTime: answerTime, questionStartTime: questionStartTime)
            newScore += points
        }

        // Store in pendingScores like human players (will be pushed during reveal)
        pendingScores[playerId] = newScore

        // Update answer info without score
        firebaseManager.updatePlayerAnswer(playerId: playerId, hasAnswered: true,
                                          answerTime: answerTime, selectedAnswer: answer, for: room.code)
    }
    
    private func checkIfAllPlayersAnswered() {
        guard let room = gameRoom else { return }
        
        // Check if all human players have answered
        let humanPlayers = room.players.values.filter { !$0.isAI }
        let allHumansAnswered = humanPlayers.allSatisfy { $0.hasAnswered }
        
        print("🔍 Checking all answered: \(humanPlayers.filter { $0.hasAnswered }.count)/\(humanPlayers.count) humans answered")
        
        if allHumansAnswered && !hasTriggeredReveal {
            print("✅ All humans answered! Triggering early reveal")
            // Lock answers
            answersLocked = true
            // Stop the timer
            gameLogic.stopTimer()
            // Trigger reveal - handleTimerComplete will set hasTriggeredReveal
            handleTimerComplete()
        }
    }

    private func handleTimerComplete() {
        // Stop periodic check
        stopPeriodicCheck()

        // Freeze timer immediately to prevent visual countdown
        gameLogic.stopTimer()
        isTimerFrozen = true
        // Don't reset timeRemaining - keep it at whatever it currently is

        // Lock answers immediately when timer completes
        answersLocked = true

        // Don't trigger multiple times - THIS is where we set the flag
        guard !hasTriggeredReveal else { return }
        hasTriggeredReveal = true

        // Timer ran out or all answered, start revealing
        showCorrectAnswer = true
        gamePhase = .roundEnd
        gameLogic.cancelAllAITimers()

        // Push scores to Firebase IMMEDIATELY when timer completes
        // This ensures scores are synced before the next round starts
        // The UI display is still controlled by showScoreUpdates flag
        pushPendingScoresToFirebase()

        // Small delay to ensure all Firebase updates are received
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.revealAnswersWithPlayers()
        }
    }

    private func pushPendingScoresToFirebase() {
        guard let room = gameRoom, let player = currentPlayer else { return }
        let capturedPendingScores = pendingScores

        if player.isHost {
            // HOST: Update all player scores
            for (playerId, playerData) in room.players {
                let finalScore = capturedPendingScores[playerId] ?? playerData.score
                firebaseManager.updatePlayerScore(playerId: playerId, score: finalScore,
                                                 hasAnswered: playerData.hasAnswered,
                                                 answerTime: playerData.lastAnswerTime,
                                                 selectedAnswer: playerData.selectedAnswer,
                                                 for: room.code)
            }
        } else {
            // NON-HOST: Update own score
            if let myPendingScore = capturedPendingScores[player.id] {
                firebaseManager.updatePlayerScore(playerId: player.id, score: myPendingScore,
                                                 hasAnswered: true,
                                                 answerTime: player.lastAnswerTime,
                                                 selectedAnswer: selectedAnswer,
                                                 for: room.code)
            }
        }
    }

    private func revealAnswersWithPlayers() {
        guard let question = currentQuestion, let room = gameRoom, let player = currentPlayer else { return }

        // Scores already pushed to Firebase in handleTimerComplete()
        // The UI display is controlled by showScoreUpdates flag

        // Sort answers alphabetically
        let sortedAnswers = shuffledAnswers.sorted()

        // Group players by their answers, sorted by answer time
        // Merge local answer data to ensure current player's answer is always included
        var answerGroups: [String: [Player]] = [:]
        for p in room.players.values {
            var playerAnswer = p.selectedAnswer
            var playerAnswerTime = p.lastAnswerTime

            // For current player, prefer local data over Firebase (which may be delayed)
            if p.id == player.id, let localAnswer = selectedAnswer, !localAnswer.isEmpty {
                playerAnswer = localAnswer
            }
            if p.id == player.id, let localTime = localAnswerTimes[player.id] {
                playerAnswerTime = questionStartTime + localTime
            }

            if let answer = playerAnswer, !answer.isEmpty {
                if answerGroups[answer] == nil {
                    answerGroups[answer] = []
                }
                var mutablePlayer = p
                // Update player copy with local data if needed
                if p.id == player.id {
                    mutablePlayer.selectedAnswer = playerAnswer
                    mutablePlayer.lastAnswerTime = playerAnswerTime
                }
                answerGroups[answer]?.append(mutablePlayer)
            }
        }

        // Sort players within each group by answer time
        for (answer, players) in answerGroups {
            answerGroups[answer] = players.sorted { p1, p2 in
                let time1 = p1.lastAnswerTime ?? Double.infinity
                let time2 = p2.lastAnswerTime ?? Double.infinity
                return time1 < time2
            }
        }

        // Reveal each answer with a delay
        var totalDelay = 0.0
        for answer in sortedAnswers {
            // Reveal the answer button color
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
                let _ = withAnimation(.easeInOut(duration: 0.3)) {
                    self.revealedAnswers.insert(answer)
                }
            }
            totalDelay += 0.3

            // Reveal players one by one for this answer
            if let players = answerGroups[answer] {
                for (index, revealPlayer) in players.enumerated() {
                    let playerDelay = totalDelay + (Double(index) * 0.25)
                    DispatchQueue.main.asyncAfter(deadline: .now() + playerDelay) {
                        if self.revealedPlayers[answer] == nil {
                            self.revealedPlayers[answer] = []
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            self.revealedPlayers[answer]?.append(revealPlayer.id)
                        }
                    }
                }
                totalDelay += Double(players.count) * 0.25
            }

            totalDelay += 0.3 // Gap before next answer
        }

        // After all revealed, show score updates, then proceed
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                self.showScoreUpdates = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.proceedToNextRound()
            }
        }
    }

    private func proceedToNextRound() {
        guard let room = gameRoom, let player = currentPlayer else { return }

        print("🎯 Proceeding to next round - current index: \(gameLogic.currentQuestionIndex), total: \(gameLogic.currentQuestions.count)")

        if gameLogic.nextQuestion() {
            // More rounds to play
            let newRound = room.currentRound + 1
            print("🎯 Moving to round \(newRound)")
            
            if player.isHost {
                firebaseManager.updateCurrentRound(newRound, for: room.code)
                firebaseManager.updateCurrentQuestion(gameLogic.currentQuestionIndex, for: room.code)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startNewRound()
                }
            }
        } else {
            // Game over - only trigger ONCE
            print("🎯 Game over! Finished all \(gameLogic.currentQuestions.count) questions")
            
            // Prevent multiple triggers
            guard gamePhase != .gameOver else {
                print("🎯 Already in game over, ignoring")
                return
            }
            
            // Only host updates Firebase
            if player.isHost {
                firebaseManager.updateGameState(.gameOver, for: room.code)
                
                // Host: short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.gamePhase = .gameOver
                }
            }
            // Non-host does NOT transition here - will be triggered by observeFirebaseRoom
            // after the reveal sequence is complete (in roundEnd phase)
        }
    }

    // MARK: - Typewriter Animation

    private func startTypewriterAnimation(text: String) {
        displayedText = ""
        typewriterTimer?.invalidate()

        var characterIndex = 0
        let characters = Array(text)

        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] timer in
            guard characterIndex < characters.count else {
                timer.invalidate()
                return
            }

            self?.displayedText.append(characters[characterIndex])
            characterIndex += 1
        }
    }

    // MARK: - Firebase Observation

    private func observeFirebaseRoom() {
        firebaseManager.$currentRoom
            .sink { [weak self] room in
                guard let self = self else { return }

                // If room becomes nil while we're in a game, the host deleted the room
                if room == nil && self.gamePhase != .menu {
                    print("🚪 Room was deleted by host, returning to menu")
                    self.cleanup()
                    return
                }

                guard let room = room else { return }

                self.gameRoom = room

                // Update current player's data
                if let playerId = self.currentPlayer?.id,
                   let updatedPlayer = room.players[playerId] {
                    self.currentPlayer = updatedPlayer
                } else if let playerId = self.currentPlayer?.id,
                          room.players[playerId] == nil,
                          self.gamePhase != .menu {
                    // Our player was removed from the room
                    print("🚪 Player removed from room, returning to menu")
                    self.cleanup()
                    return
                }

                // Sync game state
                switch room.gameState {
                case .lobby:
                    if self.gamePhase != .lobby {
                        // If returning from gameOver to lobby, reset local game state
                        if self.gamePhase == .gameOver || self.gamePhase == .playing || self.gamePhase == .roundEnd {
                            self.typewriterTimer?.invalidate()
                            self.checkTimer?.invalidate()
                            self.gameLogic.cleanup()
                            self.currentQuestion = nil
                            self.displayedText = ""
                            self.shuffledAnswers = []
                            self.selectedAnswer = nil
                            self.hasAnswered = false
                            self.showCorrectAnswer = false
                            self.revealedAnswers = []
                            self.revealedPlayers = [:]
                            self.showScoreUpdates = false
                            self.answersLocked = false
                            self.hasTriggeredReveal = false
                            self.isTimerFrozen = false
                            self.scoresBeforeRound = [:]
                            self.pendingScores = [:]
                            self.questionStartTime = 0
                            self.lastObservedQuestionIndex = -1
                            self.lastObservedTimerEndTime = 0
                            self.isExpectingFreshTimer = false
                            self.currentRoundId = 0
                            self.localAnswerTimes = [:]
                        }
                        self.gamePhase = .lobby
                    }
                case .playing:
                    // NON-HOST: When entering playing state or question changes
                    if let player = self.currentPlayer, !player.isHost {
                        let questionChanged = room.currentQuestionIndex != self.lastObservedQuestionIndex
                        let timerChanged = room.timerEndTime != self.lastObservedTimerEndTime && room.timerEndTime > 0
                        
                        print("🔄 NON-HOST: Observed .playing - questionChanged: \(questionChanged), timerChanged: \(timerChanged), currentIndex: \(room.currentQuestionIndex), lastObserved: \(self.lastObservedQuestionIndex), phase: \(self.gamePhase)")
                        
                        // Load questions on first entry - get question IDs from Firebase
                        if self.gameLogic.currentQuestions.isEmpty {
                            print("🔄 NON-HOST: Loading questions from Firebase")
                            self.firebaseManager.getQuestionIds(for: room.code) { questionIds in
                                if let questionIds = questionIds {
                                    print("🔄 NON-HOST: Received \(questionIds.count) question IDs from Firebase")
                                    print("🔄 NON-HOST: First 3 questions: \(questionIds.prefix(3))")
                                    
                                    // Load questions by ID
                                    self.gameLogic.currentQuestions = MovieQuotes.shared.getQuestionsByIds(questionIds)
                                    print("🔄 NON-HOST: Loaded \(self.gameLogic.currentQuestions.count) questions")
                                    
                                    // After loading, trigger sync if needed
                                    if questionChanged || timerChanged || self.gamePhase == .lobby {
                                        self.lastObservedQuestionIndex = room.currentQuestionIndex
                                        self.lastObservedTimerEndTime = room.timerEndTime
                                        self.gameLogic.currentQuestionIndex = room.currentQuestionIndex
                                        self.syncNonHostGameState(room: room)
                                    }
                                } else {
                                    print("❌ NON-HOST: Failed to get question IDs from Firebase")
                                }
                            }
                            return // Wait for questions to load before syncing
                        }
                        
                        // SYNC IMMEDIATELY when:
                        // 1. Question changed, OR
                        // 2. Timer changed (new round started), OR
                        // 3. Entering from lobby for the first time
                        // DO NOT sync repeatedly when in roundEnd!
                        if questionChanged || timerChanged || self.gamePhase == .lobby {
                            print("🔄 NON-HOST: Triggering sync - questionChanged: \(questionChanged), timerChanged: \(timerChanged), from lobby: \(self.gamePhase == .lobby)")

                            // Track if we're expecting a fresh timer after question change
                            // This prevents the timer bar from jumping to zero when sync is called
                            // with a stale timer before the new timer update arrives
                            if questionChanged {
                                self.isExpectingFreshTimer = true
                            }
                            if timerChanged && self.isExpectingFreshTimer {
                                self.isExpectingFreshTimer = false
                            }

                            self.lastObservedQuestionIndex = room.currentQuestionIndex
                            self.lastObservedTimerEndTime = room.timerEndTime
                            self.gameLogic.currentQuestionIndex = room.currentQuestionIndex

                            // Sync IMMEDIATELY, no delay!
                            self.syncNonHostGameState(room: room)
                        }
                    }
                case .roundEnd:
                    // NON-HOST: If host is in roundEnd and we're not, sync to roundEnd
                    if let player = self.currentPlayer, !player.isHost {
                        if self.gamePhase == .playing {
                            self.handleTimerComplete()
                        }
                    }
                case .gameOver:
                    // Non-host: Only switch to game over when we're in roundEnd (reveal complete)
                    // This ensures all animations finish before showing victory screen
                    if self.gamePhase == .roundEnd {
                        print("🔄 NON-HOST: Transitioning to game over after reveals complete")
                        self.gamePhase = .gameOver
                    } else {
                        print("🔄 NON-HOST: Host signaled gameOver, but waiting for reveals to complete (current phase: \(self.gamePhase))")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // NON-HOST: Sync game state from Firebase
    private func syncNonHostGameState(room: GameRoom) {
        guard let player = currentPlayer, !player.isHost,
              let question = gameLogic.getCurrentQuestion() else {
            print("❌ NON-HOST: Failed to sync - no question available")
            return
        }

        print("🔄 NON-HOST: Syncing question #\(gameLogic.currentQuestionIndex)")
        print("🔄 NON-HOST: Question ID: \(question.id), Quote: \(question.quote.prefix(30))...")

        // CRITICAL: Stop any existing timer and freeze FIRST to prevent race conditions
        gameLogic.stopTimer()
        isTimerFrozen = true

        // Set timeRemaining to full value IMMEDIATELY before any other state changes
        // This prevents the timer bar from jumping to zero before going back to full
        timeRemaining = 10.0

        // Set up the question
        currentQuestion = question
        // Build answers array manually (don't use question.allAnswers as it's randomly shuffled)
        var answersToShuffle = question.wrongAnswers
        answersToShuffle.append(question.correctAnswer)
        // Use same deterministic shuffle as host
        shuffledAnswers = deterministicShuffle(array: answersToShuffle, seed: question.id.hashValue)

        print("🔄 NON-HOST: Shuffled answers: \(shuffledAnswers)")

        displayedText = ""
        selectedAnswer = nil
        hasAnswered = false
        showCorrectAnswer = false
        revealedAnswers = []
        revealedPlayers = [:]
        showScoreUpdates = false
        answersLocked = false
        hasTriggeredReveal = false

        // Increment round ID for tracking stale data (same as host does)
        currentRoundId += 1

        // Clear local answer times for new round - prevents stale time display
        localAnswerTimes = [:]

        // Capture scores BEFORE this round
        // These are the scores at the END of the previous round, which is correct
        scoresBeforeRound = [:]
        for (id, playerData) in room.players {
            scoresBeforeRound[id] = playerData.score
        }

        // Start typewriter animation
        startTypewriterAnimation(text: question.quote)
        
        // Sync timer from Firebase - wait for valid timerEndTime
        guard room.timerEndTime > 0 else {
            print("⚠️ NON-HOST: Invalid timerEndTime (\(room.timerEndTime)), waiting for update")
            return
        }
        
        let endTime = room.timerEndTime
        questionStartTime = endTime - 10.0
        
        // Calculate current time remaining
        let now = Date().timeIntervalSince1970
        let remaining = endTime - now
        
        print("🔄 NON-HOST: Timer - endTime: \(endTime), startTime: \(questionStartTime), remaining: \(remaining)")
        
        // Check if this appears to be a stale timer from the previous round
        // A fresh timer for a new round should have close to 10 seconds remaining
        // If we're expecting a fresh timer (question just changed) and remaining is low,
        // the timer update hasn't arrived yet - wait for it
        let isFreshTimer = remaining > 8.0

        if isExpectingFreshTimer && !isFreshTimer && remaining > -8.0 {
            // Question changed but timer is stale - wait for fresh timer update
            // Keep timeRemaining at 10.0 (already set above) to prevent visual glitch
            print("⚠️ NON-HOST: Timer appears stale for new question (remaining: \(remaining)s), keeping at full and waiting for fresh timer")
            gamePhase = .playing
            startPeriodicCheck()
            // Don't start actual timer or update timeRemaining - wait for fresh timer
            return
        }

        // Start timer even if we're late - give player chance to answer
        // The timer will just show less time remaining
        if remaining > -8.0 {  // Allow up to 8 seconds late (still 2 seconds to answer)
            let adjustedRemaining = max(0.1, remaining) // Ensure at least 0.1 seconds

            // Start the timer (we already stopped any existing timer at the start of this function)
            gameLogic.startTimer(endTime: endTime, onTick: { [weak self] remaining in
                guard let self = self, !self.isTimerFrozen else { return }
                self.timeRemaining = remaining
            }, onComplete: { [weak self] in
                self?.handleTimerComplete()
            })

            // Now set the actual remaining time and unfreeze
            // The timeRemaining was already set to 10.0 at the start to prevent visual glitch
            // Now update it to the actual remaining time
            timeRemaining = adjustedRemaining
            isTimerFrozen = false
            gamePhase = .playing

            // Start periodic check for all players answered
            startPeriodicCheck()

            if remaining < 0 {
                print("⚠️ NON-HOST: Synced late (timer started \(abs(remaining)) seconds ago), but allowing gameplay")
            }
        } else {
            print("⚠️ NON-HOST: Timer expired too long ago (\(abs(remaining))s), going to reveal")
            // Timer expired way too long ago, go straight to reveal
            handleTimerComplete()
        }
    }

    func getSortedPlayers() -> [Player] {
        guard let room = gameRoom else { return [] }
        return gameLogic.getRankings(players: Array(room.players.values))
    }

    func getAnswerTimeForPlayer(_ player: Player) -> String? {
        // Only show if player actually answered (not just time ran out)
        guard let selectedAnswer = player.selectedAnswer, !selectedAnswer.isEmpty else {
            return nil
        }

        // FIRST: Try to use locally calculated answer time (most reliable)
        if let localElapsed = localAnswerTimes[player.id] {
            // Validate the local time is reasonable
            if localElapsed >= 0 && localElapsed <= 10.0 && !localElapsed.isNaN && !localElapsed.isInfinite {
                return String(format: "%.1fs", localElapsed)
            }
        }

        // FALLBACK: Calculate from Firebase data (for other players)
        guard let answerTime = player.lastAnswerTime, answerTime > 0, questionStartTime > 0 else {
            return nil
        }

        let elapsed = answerTime - questionStartTime

        // Protect against negative, invalid, or stale times
        guard elapsed >= 0 && elapsed <= 10.0 && !elapsed.isNaN && !elapsed.isInfinite else {
            return nil
        }

        return String(format: "%.1fs", elapsed)
    }
    
    func getDisplayScore(for player: Player) -> Int {
        // During gameplay (before scores revealed), show old score
        if !showScoreUpdates {
            return scoresBeforeRound[player.id] ?? player.score
        }
        // After reveal, show current score
        return player.score
    }

    /// Check if a player's "answered" indicator should be shown.
    /// This validates that the answer data is for the current round, not stale data from previous rounds.
    func shouldShowAnsweredIndicator(for player: Player) -> Bool {
        // Must have answered flag set
        guard player.hasAnswered else { return false }

        // Must have a selected answer (not empty string from reset)
        guard let selectedAnswer = player.selectedAnswer, !selectedAnswer.isEmpty else {
            return false
        }

        // If we have a valid answer time (local or calculated), the data is fresh
        if getAnswerTimeForPlayer(player) != nil {
            return true
        }

        // If no valid answer time but selectedAnswer is set, might be transitioning
        // Check if the lastAnswerTime is reasonable (within this round's timeframe)
        if let answerTime = player.lastAnswerTime, answerTime > 0, questionStartTime > 0 {
            let elapsed = answerTime - questionStartTime
            // If elapsed is way out of range, this is stale data
            if elapsed < -5.0 || elapsed > 15.0 {
                return false
            }
        }

        return true
    }

    // MARK: - Emoji Selection

    func updatePlayerEmoji(_ emoji: String) {
        guard let player = currentPlayer, let room = gameRoom else { return }
        // Check emoji not already taken by another player
        let takenEmojis = room.players.values.filter { $0.id != player.id }.map { $0.avatarEmoji }
        guard !takenEmojis.contains(emoji) else { return }

        currentPlayer?.avatarEmoji = emoji
        firebaseManager.updatePlayerEmoji(playerId: player.id, emoji: emoji, for: room.code)
    }

    func isEmojiTaken(_ emoji: String) -> Bool {
        guard let room = gameRoom, let player = currentPlayer else { return false }
        return room.players.values.contains { $0.id != player.id && $0.avatarEmoji == emoji }
    }

    // MARK: - Return to Lobby

    func returnToLobby() {
        guard let room = gameRoom, let player = currentPlayer else { return }

        // Reset game state but keep the room
        typewriterTimer?.invalidate()
        checkTimer?.invalidate()
        gameLogic.cleanup()

        currentQuestion = nil
        displayedText = ""
        shuffledAnswers = []
        selectedAnswer = nil
        hasAnswered = false
        showCorrectAnswer = false
        revealedAnswers = []
        revealedPlayers = [:]
        showScoreUpdates = false
        answersLocked = false
        hasTriggeredReveal = false
        isTimerFrozen = false
        scoresBeforeRound = [:]
        pendingScores = [:]
        questionStartTime = 0
        lastObservedQuestionIndex = -1
        lastObservedTimerEndTime = 0
        isExpectingFreshTimer = false
        currentRoundId = 0
        localAnswerTimes = [:]

        gamePhase = .lobby

        // Host resets the room state in Firebase
        if player.isHost {
            firebaseManager.resetRoomForNewGame(code: room.code)
        }
    }

    // MARK: - Cleanup

    private func cleanup() {
        gameLogic.cleanup()
        typewriterTimer?.invalidate()
        checkTimer?.invalidate()
        firebaseManager.stopObservingRoom()
        gamePhase = .menu
        currentPlayer = nil
        gameRoom = nil
        currentQuestion = nil
        displayedText = ""
        shuffledAnswers = []
        selectedAnswer = nil
        hasAnswered = false
        showCorrectAnswer = false
        revealedAnswers = []
        revealedPlayers = [:]
        showScoreUpdates = false
        answersLocked = false
        hasTriggeredReveal = false
        isTimerFrozen = false
        scoresBeforeRound = [:]
        pendingScores = [:]
        questionStartTime = 0
        lastObservedQuestionIndex = -1
        lastObservedTimerEndTime = 0
        isExpectingFreshTimer = false
        currentRoundId = 0
        localAnswerTimes = [:]
    }

    deinit {
        typewriterTimer?.invalidate()
        checkTimer?.invalidate()
        gameLogic.cleanup()
    }
}
