import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) var moodHistory: [MoodEntry]
    @ObservedObject var viewModel: MainViewModel

    @State private var showDeleteAlert = false
    @State private var entryToDelete: MoodEntry? = nil
    @State private var showDetailSheet = false
    @State private var detailEntry: MoodEntry? = nil

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
                                .contextMenu {
                                    Button(role: .destructive) {
                                        entryToDelete = entry
                                        showDeleteAlert = true
                                    } label: {
                                        Label("刪除這筆紀錄", systemImage: "trash")
                                    }

                                    Button {
                                        detailEntry = entry
                                        showDetailSheet = true
                                    } label: {
                                        Label("詳細完整內容", systemImage: "doc.text.magnifyingglass")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
        }
        .alert("確定要刪除這筆紀錄嗎？", isPresented: $showDeleteAlert) {
            Button("刪除", role: .destructive) {
                if let entry = entryToDelete {
                    viewModel.deleteEntry(entry)
                }
                entryToDelete = nil
            }
            Button("取消", role: .cancel) {
                entryToDelete = nil
            }
        } message: {
            Text("刪除後無法復原，請確認是否要刪除這一天的紀錄嗎？")
        }
        .sheet(isPresented: $showDetailSheet) {
            if let entry = detailEntry {
                MoodDetailView(entry: entry)
            }
        }
    }
}

struct MoodCard: View {
    let entry: MoodEntry
    @Environment(\.colorScheme) var colorScheme

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
        .frame(width: 380, height: 180)
        .background(
            colorScheme == .dark ?
                Color.white.opacity(0.1) :
                Color.blue.opacity(0.1)
        )
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
