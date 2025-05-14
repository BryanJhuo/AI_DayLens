import SwiftUI

struct MoodDetailView: View {
    let entry: MoodEntry
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("📅 紀錄日期")
                            .font(.headline)
                        Text(formattedDate(entry.date))
                            .font(.body)

                        Divider()

                        Text("🧠 分析情緒")
                            .font(.headline)
                        Text("\(emojiForEmotion(entry.emotion)) \(entry.emotion)")
                            .font(.title2)

                        Divider()
                    }

                    Group {
                        Text("📝 使用者輸入")
                            .font(.headline)
                        Text(entry.userInput)
                            .font(.body)
                            .foregroundColor(.primary)

                        Divider()

                        Text("💬 AI 小語")
                            .font(.headline)
                        Text(entry.message)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = entry.message
                                }) {
                                    Label("複製文字", systemImage: "doc.on.doc")
                                }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("完整紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("關閉") {
                        dismiss()
                    }
                }
            }
            }
        }

    func emojiForEmotion(_ emotion: String) -> String {
        switch emotion {
        case "快樂": return "😄"
        case "悲傷": return "😢"
        case "焦慮": return "😰"
        case "放鬆": return "🧘"
        case "中性": return "😐"
        default: return "🤔"
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}