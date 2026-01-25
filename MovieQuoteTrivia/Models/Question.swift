import Foundation

struct Question: Identifiable, Codable {
    var id: String
    var quote: String
    var correctAnswer: String
    var wrongAnswers: [String]
    var year: Int
    var difficulty: Difficulty

    enum Difficulty: String, Codable {
        case easy, medium, hard
    }

    var allAnswers: [String] {
        var answers = wrongAnswers
        answers.append(correctAnswer)
        return answers.shuffled()
    }

    // Convenience initializer for creating questions (used by MovieQuotes)
    init(quote: String, correctAnswer: String, wrongAnswers: [String], year: Int, difficulty: Difficulty = .medium) {
        // Use a deterministic ID based on a simple hash of the quote
        // We can't use Swift's hashValue as it's randomized per-run for security
        // Instead, create a simple deterministic hash
        var hash: UInt64 = 5381
        for char in quote.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }
        self.id = String(format: "%016llX", hash)
        self.quote = quote
        self.correctAnswer = correctAnswer
        self.wrongAnswers = wrongAnswers
        self.year = year
        self.difficulty = difficulty
    }

    // Full initializer with custom ID (for compatibility)
    init(id: String = UUID().uuidString,
         quote: String,
         correctAnswer: String,
         wrongAnswers: [String],
         year: Int,
         difficulty: Difficulty = .medium) {
        self.id = id
        self.quote = quote
        self.correctAnswer = correctAnswer
        self.wrongAnswers = wrongAnswers
        self.year = year
        self.difficulty = difficulty
    }
}
