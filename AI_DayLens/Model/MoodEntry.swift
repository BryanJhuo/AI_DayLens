import Foundation
import SwiftData

@Model 
class MoodEntry {
    var date: Date
    var userInput: String
    var emotion: String
    var message: String
    var dayString: String

    init(date: Date, userInput: String, emotion: String, message: String) {
        self.date = date
        self.userInput = userInput
        self.emotion = emotion
        self.message = message
        self.dayString = MoodEntry.formatDate(date)
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}