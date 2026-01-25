import Foundation

struct GameRoom: Codable {
    var id: String
    var code: String
    var hostId: String
    var players: [String: Player]
    var currentRound: Int
    var totalRounds: Int
    var currentQuestionIndex: Int
    var gameState: GameState
    var timerEndTime: TimeInterval
    var createdAt: TimeInterval
    var isSinglePlayer: Bool
    var difficulty: Question.Difficulty

    enum GameState: String, Codable {
        case lobby
        case playing
        case roundEnd
        case gameOver
    }

    init(id: String = UUID().uuidString,
         code: String,
         hostId: String,
         players: [String: Player] = [:],
         currentRound: Int = 0,
         totalRounds: Int = 10,
         currentQuestionIndex: Int = 0,
         gameState: GameState = .lobby,
         timerEndTime: TimeInterval = 0,
         isSinglePlayer: Bool = false,
         difficulty: Question.Difficulty = .medium) {
        self.id = id
        self.code = code
        self.hostId = hostId
        self.players = players
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.currentQuestionIndex = currentQuestionIndex
        self.gameState = gameState
        self.timerEndTime = timerEndTime
        self.createdAt = Date().timeIntervalSince1970
        self.isSinglePlayer = isSinglePlayer
        self.difficulty = difficulty
    }

    func toDictionary() -> [String: Any] {
        var playersDict: [String: Any] = [:]
        for (key, player) in players {
            playersDict[key] = player.toDictionary()
        }

        return [
            "id": id,
            "code": code,
            "hostId": hostId,
            "players": playersDict,
            "currentRound": currentRound,
            "totalRounds": totalRounds,
            "currentQuestionIndex": currentQuestionIndex,
            "gameState": gameState.rawValue,
            "timerEndTime": timerEndTime,
            "createdAt": createdAt,
            "isSinglePlayer": isSinglePlayer,
            "difficulty": difficulty.rawValue
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> GameRoom? {
        guard let id = dict["id"] as? String,
              let code = dict["code"] as? String,
              let hostId = dict["hostId"] as? String,
              let playersDict = dict["players"] as? [String: [String: Any]],
              let currentRound = dict["currentRound"] as? Int,
              let totalRounds = dict["totalRounds"] as? Int,
              let currentQuestionIndex = dict["currentQuestionIndex"] as? Int,
              let gameStateString = dict["gameState"] as? String,
              let gameState = GameState(rawValue: gameStateString),
              let timerEndTime = dict["timerEndTime"] as? TimeInterval,
              let createdAt = dict["createdAt"] as? TimeInterval,
              let isSinglePlayer = dict["isSinglePlayer"] as? Bool else {
            return nil
        }

        let difficultyString = dict["difficulty"] as? String ?? "medium"
        let difficulty = Question.Difficulty(rawValue: difficultyString) ?? .medium

        var players: [String: Player] = [:]
        for (key, playerDict) in playersDict {
            if let player = Player.fromDictionary(playerDict) {
                players[key] = player
            }
        }

        var room = GameRoom(id: id, code: code, hostId: hostId, players: players,
                           currentRound: currentRound, totalRounds: totalRounds,
                           currentQuestionIndex: currentQuestionIndex, gameState: gameState,
                           timerEndTime: timerEndTime, isSinglePlayer: isSinglePlayer,
                           difficulty: difficulty)
        room.createdAt = createdAt
        return room
    }
}
