import SwiftUI

struct MediumWidgetView: View {
    let entry: MoodWidgetEntry

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let mood = entry.mood {
                // 有當天紀錄
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(emoji(for: mood.emotion)) \(mood.emotion)")
                        .font(.title2)
                        .bold()

                    Text(mood.message)
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
            } else {
                // 尚未紀錄
                VStack(alignment: .leading, spacing: 6) {
                    Text("🕊️ 尚未記錄")
                        .font(.title2)
                        .bold()

                    Text("今天還沒有心情紀錄。\n快打開 App 寫下一點點想法吧！")
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
            }

            Spacer()
        }
        .padding()
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
