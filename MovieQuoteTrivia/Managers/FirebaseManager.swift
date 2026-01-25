import Foundation
import Combine
import FirebaseCore
import FirebaseDatabase

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    private var database: DatabaseReference?
    private var roomListener: DatabaseHandle?
    private var playersListener: DatabaseHandle?

    @Published var currentRoom: GameRoom?
    @Published var isConnected: Bool = false
    @Published var connectionError: String?

    private init() {
        setupFirebase()
    }

    private func setupFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        database = Database.database().reference()
        setupConnectionMonitoring()
    }

    private func setupConnectionMonitoring() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value) { [weak self] snapshot in
            if let connected = snapshot.value as? Bool {
                self?.isConnected = connected
            }
        }
    }

    // MARK: - Room Management

    func createRoom(hostPlayer: Player, isSinglePlayer: Bool, difficulty: Question.Difficulty, completion: @escaping (Result<GameRoom, Error>) -> Void) {
        guard let database = database else {
            completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])))
            return
        }

        let code = generateRoomCode()
        let roomId = UUID().uuidString

        var room = GameRoom(id: roomId, code: code, hostId: hostPlayer.id, isSinglePlayer: isSinglePlayer, difficulty: difficulty)
        room.players[hostPlayer.id] = hostPlayer

        let roomRef = database.child("rooms").child(code)
        roomRef.setValue(room.toDictionary()) { [weak self] error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                self?.currentRoom = room
                self?.observeRoom(code: code)
                completion(.success(room))
            }
        }
    }

    func joinRoom(code: String, player: Player, completion: @escaping (Result<GameRoom, Error>) -> Void) {
        guard let database = database else {
            completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])))
            return
        }

        let roomRef = database.child("rooms").child(code)

        roomRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard snapshot.exists(),
                  let roomDict = snapshot.value as? [String: Any],
                  var room = GameRoom.fromDictionary(roomDict) else {
                completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room not found"])))
                return
            }

            if room.gameState != .lobby {
                completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Game already in progress"])))
                return
            }

            if room.players.count >= 6 {
                completion(.failure(NSError(domain: "Firebase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Room is full"])))
                return
            }

            room.players[player.id] = player
            roomRef.child("players").child(player.id).setValue(player.toDictionary()) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    self?.currentRoom = room
                    self?.observeRoom(code: code)
                    completion(.success(room))
                }
            }
        }
    }

    func observeRoom(code: String) {
        guard let database = database else { return }

        let roomRef = database.child("rooms").child(code)

        roomListener = roomRef.observe(.value) { [weak self] snapshot in
            guard snapshot.exists(),
                  let roomDict = snapshot.value as? [String: Any],
                  let room = GameRoom.fromDictionary(roomDict) else {
                return
            }

            DispatchQueue.main.async {
                self?.currentRoom = room
            }
        }
    }

    func updateGameState(_ state: GameRoom.GameState, for code: String) {
        database?.child("rooms").child(code).child("gameState").setValue(state.rawValue)
    }

    func updateCurrentRound(_ round: Int, for code: String) {
        database?.child("rooms").child(code).child("currentRound").setValue(round)
    }

    func updateCurrentQuestion(_ index: Int, for code: String) {
        database?.child("rooms").child(code).child("currentQuestionIndex").setValue(index)
    }

    func updateTimer(endTime: TimeInterval, for code: String) {
        database?.child("rooms").child(code).child("timerEndTime").setValue(endTime)
    }

    func updatePlayerScore(playerId: String, score: Int, hasAnswered: Bool, answerTime: TimeInterval?, selectedAnswer: String?, for code: String) {
        let playerRef = database?.child("rooms").child(code).child("players").child(playerId)
        playerRef?.child("score").setValue(score)
        playerRef?.child("hasAnswered").setValue(hasAnswered)
        if let answerTime = answerTime {
            playerRef?.child("lastAnswerTime").setValue(answerTime)
        }
        if let selectedAnswer = selectedAnswer {
            playerRef?.child("selectedAnswer").setValue(selectedAnswer)
        }
    }
    
    // Update answer info WITHOUT score (to prevent score leak before reveal)
    func updatePlayerAnswer(playerId: String, hasAnswered: Bool, answerTime: TimeInterval?, selectedAnswer: String?, for code: String) {
        let playerRef = database?.child("rooms").child(code).child("players").child(playerId)
        playerRef?.child("hasAnswered").setValue(hasAnswered)
        if let answerTime = answerTime {
            playerRef?.child("lastAnswerTime").setValue(answerTime)
        }
        if let selectedAnswer = selectedAnswer {
            playerRef?.child("selectedAnswer").setValue(selectedAnswer)
        }
    }

    func addPlayer(_ player: Player, to code: String) {
        database?.child("rooms").child(code).child("players").child(player.id).setValue(player.toDictionary())
    }

    func resetPlayersAnswered(for code: String) {
        guard let currentRoom = currentRoom else { return }

        for playerId in currentRoom.players.keys {
            let playerRef = database?.child("rooms").child(code).child("players").child(playerId)
            playerRef?.child("hasAnswered").setValue(false)
            playerRef?.child("lastAnswerTime").setValue(0)
            playerRef?.child("selectedAnswer").setValue("")
        }
    }
    
    func storeQuestionIds(_ questionIds: [String], for code: String) {
        database?.child("rooms").child(code).child("questionIds").setValue(questionIds)
    }
    
    func getQuestionIds(for code: String, completion: @escaping ([String]?) -> Void) {
        database?.child("rooms").child(code).child("questionIds").observeSingleEvent(of: .value) { snapshot in
            if let questionIds = snapshot.value as? [String] {
                completion(questionIds)
            } else {
                completion(nil)
            }
        }
    }

    func leaveRoom(playerId: String, code: String) {
        database?.child("rooms").child(code).child("players").child(playerId).removeValue()
        stopObservingRoom()
    }

    func deleteRoom(code: String) {
        database?.child("rooms").child(code).removeValue()
        stopObservingRoom()
    }

    func stopObservingRoom() {
        if let listener = roomListener {
            database?.child("rooms").removeObserver(withHandle: listener)
            roomListener = nil
        }
        currentRoom = nil
    }

    // MARK: - Helper Methods

    private func generateRoomCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // Removed ambiguous characters
        return String((0..<6).map { _ in characters.randomElement()! })
    }

    // MARK: - Cleanup

    deinit {
        stopObservingRoom()
    }
}
