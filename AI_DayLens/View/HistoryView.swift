import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) var moodHistory: [MoodEntry]

    var body: some View {
        VStack(alignment:.leading) {
            Text("歷史紀錄畫面")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .padding(.leading)
            
            if moodHistory.isEmpty {
                Spacer()
                Text("目前還沒有任何紀錄喔！")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(moodHistory) { entry in 
                            MoodCard(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
        }
    }
}

struct MoodCard: View {
    let entry: MoodEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDate(entry.date))
                .font(.headline)
                .foregroundColor(.secondary)

            Text("\(emojiForEmotion(entry.emotion)) \(entry.emotion)") 
                .font(.title2)
                .fontWeight(.bold)

            Text(entry.message)
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(3)
                .padding(.top, 2)

            Spacer()
        }
        .padding()
        .frame(width: 240, height: 180)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    func emojiForEmotion(_ emotion: String) -> String {
        switch emotion {
        case "快樂":
            return "😄"
        case "悲傷":
            return "😢"
        case "焦慮":
            return "😰"
        case "放鬆":
            return "🧘"
        case "中性":
            return "😐"
        default:
            return "🤔"
        }
    }

}
