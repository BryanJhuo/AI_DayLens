import SwiftUI

struct MoodWidgetView: View {
    let entry: MoodWidgetEntry

    var body: some View {
        if let mood = entry.mood {
            VStack(spacing: 4) {
                Text(emoji(for: mood.emotion))
                    .font(.system(size: 40))
                Text(mood.message)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        } else {
            VStack {
                Text("🕊️")
                    .font(.system(size: 40))
                Text("今天還沒有心情紀錄")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
    }

    func emoji(for emotion: String) -> String {
        switch emotion {
        case "快樂": return "😄"
        case "悲傷": return "😢"
        case "焦慮": return "😰"
        case "放鬆": return "🧘"
        case "中性": return "😐"
        default: return "🤔"
        }
    }
}
