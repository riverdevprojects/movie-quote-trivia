import Foundation
import SwiftUI

struct Player: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var avatarEmoji: String
    var score: Int
    var isHost: Bool
    var isAI: Bool
    var hasAnswered: Bool
    var lastAnswerTime: TimeInterval?
    var selectedAnswer: String?

    init(id: String = UUID().uuidString,
         name: String,
         avatarEmoji: String = "🎬",
         score: Int = 0,
         isHost: Bool = false,
         isAI: Bool = false,
         hasAnswered: Bool = false,
         lastAnswerTime: TimeInterval? = nil,
         selectedAnswer: String? = nil) {
        self.id = id
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.score = score
        self.isHost = isHost
        self.isAI = isAI
        self.hasAnswered = hasAnswered
        self.lastAnswerTime = lastAnswerTime
        self.selectedAnswer = selectedAnswer
    }

    // Firebase dictionary conversion
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "avatarEmoji": avatarEmoji,
            "score": score,
            "isHost": isHost,
            "isAI": isAI,
            "hasAnswered": hasAnswered,
            "lastAnswerTime": lastAnswerTime ?? 0,
            "selectedAnswer": selectedAnswer ?? ""
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> Player? {
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let avatarEmoji = dict["avatarEmoji"] as? String,
              let score = dict["score"] as? Int,
              let isHost = dict["isHost"] as? Bool,
              let isAI = dict["isAI"] as? Bool,
              let hasAnswered = dict["hasAnswered"] as? Bool else {
            return nil
        }

        let lastAnswerTime = dict["lastAnswerTime"] as? TimeInterval
        let selectedAnswer = dict["selectedAnswer"] as? String

        return Player(id: id, name: name, avatarEmoji: avatarEmoji,
                     score: score, isHost: isHost, isAI: isAI,
                     hasAnswered: hasAnswered, lastAnswerTime: lastAnswerTime,
                     selectedAnswer: selectedAnswer)
    }

    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}
