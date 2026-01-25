import Foundation
import Combine

class GameLogicManager: ObservableObject {
    static let shared = GameLogicManager()

    @Published var currentQuestions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var timeRemaining: Double = 10.0
    @Published var isTimerRunning: Bool = false

    private var timerCancellable: AnyCancellable?
    private var aiTimers: [String: Timer] = [:]

    private let maxTime: Double = 10.0
    private let maxPoints: Int = 1000
    private let minPoints: Int = 100

    private init() {}

    // MARK: - Game Setup

    func startNewGame(totalRounds: Int = 10) {
        currentQuestions = MovieQuotes.shared.getRandomQuestions(count: totalRounds)
        currentQuestionIndex = 0
    }

    func getCurrentQuestion() -> Question? {
        guard currentQuestionIndex < currentQuestions.count else { return nil }
        return currentQuestions[currentQuestionIndex]
    }

    // MARK: - Timer Management

    func startTimer(endTime: TimeInterval, onTick: @escaping (Double) -> Void, onComplete: @escaping () -> Void) {
        stopTimer()
        isTimerRunning = true

        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                let remaining = endTime - Date().timeIntervalSince1970
                self.timeRemaining = max(0, remaining)

                onTick(self.timeRemaining)

                if self.timeRemaining <= 0 {
                    self.stopTimer()
                    onComplete()
                }
            }
    }

    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        isTimerRunning = false
    }

    // MARK: - Scoring

    func calculateScore(answerTime: TimeInterval, questionStartTime: TimeInterval) -> Int {
        let elapsed = answerTime - questionStartTime
        let timeRatio = max(0, min(1, 1 - (elapsed / maxTime)))

        // Score ranges from minPoints to maxPoints based on speed
        let score = Int(Double(minPoints) + (Double(maxPoints - minPoints) * timeRatio))
        return score
    }

    func isCorrectAnswer(selectedAnswer: String, question: Question) -> Bool {
        return selectedAnswer == question.correctAnswer
    }

    // MARK: - AI Bot Management

    func scheduleAIAnswers(aiPlayers: [Player], roomCode: String, questionStartTime: TimeInterval, correctAnswer: String, difficulty: Question.Difficulty, onAnswer: @escaping (String, TimeInterval, String) -> Void) {
        cancelAllAITimers()

        for aiPlayer in aiPlayers {
            let delay = generateAIResponseDelay()
            let willAnswerCorrectly = shouldAIAnswerCorrectly(difficulty: difficulty)

            let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                guard let self = self,
                      let currentQuestion = self.getCurrentQuestion() else { return }

                let answer: String
                if willAnswerCorrectly {
                    answer = correctAnswer
                } else {
                    // Pick a random wrong answer
                    let wrongAnswers = currentQuestion.wrongAnswers
                    answer = wrongAnswers.randomElement() ?? currentQuestion.wrongAnswers[0]
                }

                let answerTime = questionStartTime + delay
                onAnswer(aiPlayer.id, answerTime, answer)
            }

            aiTimers[aiPlayer.id] = timer
        }
    }

    func cancelAllAITimers() {
        for timer in aiTimers.values {
            timer.invalidate()
        }
        aiTimers.removeAll()
    }

    private func generateAIResponseDelay() -> TimeInterval {
        // AI responds between 2-8 seconds, with bias toward middle range
        let random = Double.random(in: 0...1)
        let skewed = pow(random, 1.5) // Skew distribution slightly toward faster responses
        return 2.0 + (skewed * 6.0)
    }

    private func shouldAIAnswerCorrectly(difficulty: Question.Difficulty) -> Bool {
        let accuracy: Double
        switch difficulty {
        case .easy:
            accuracy = 0.5  // 50% correct on easy
        case .medium:
            accuracy = 0.7  // 70% correct on medium
        case .hard:
            accuracy = 0.85 // 85% correct on hard
        }
        return Double.random(in: 0...1) < accuracy
    }

    // MARK: - AI Player Generation

    func generateAIPlayers(count: Int) -> [Player] {
        let aiNames = ["MovieBuff", "CinemaFan", "FilmGuru", "QuoteMaster", "ReelExpert"]
        let aiEmojis = ["🤖", "🎭", "🎪", "🎨", "🎯"]

        var aiPlayers: [Player] = []
        for i in 0..<min(count, aiNames.count) {
            let aiPlayer = Player(
                id: "ai_\(UUID().uuidString)",
                name: aiNames[i],
                avatarEmoji: aiEmojis[i],
                score: 0,
                isHost: false,
                isAI: true
            )
            aiPlayers.append(aiPlayer)
        }

        return aiPlayers
    }

    // MARK: - Game Progression

    func nextQuestion() -> Bool {
        currentQuestionIndex += 1
        return currentQuestionIndex < currentQuestions.count
    }

    func isGameOver() -> Bool {
        return currentQuestionIndex >= currentQuestions.count
    }

    func getRankings(players: [Player]) -> [Player] {
        return players.sorted { $0.score > $1.score }
    }

    // MARK: - Cleanup

    func cleanup() {
        stopTimer()
        cancelAllAITimers()
        currentQuestions.removeAll()
        currentQuestionIndex = 0
        timeRemaining = 10.0
    }
}
