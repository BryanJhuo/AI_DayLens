import SwiftUI
import SwiftData
import Charts

struct TrendChartView: View {
    @ObservedObject var viewModel: MainViewModel
    @Query(sort: \MoodEntry.date, order: .forward) var moodHistory: [MoodEntry]

    // 用來對應情緒 → 數值
    let emotionScale: [String: Int] = [
        "快樂": 5,
        "放鬆": 4,
        "中性": 3,
        "焦慮": 2,
        "悲傷": 1
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Text("📈 最近情緒趨勢")
                .font(.title)
                .bold()
                .padding(.horizontal)

            if moodHistory.isEmpty {
                Spacer()
                Text("目前還沒有紀錄可以顯示喔！")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                Chart {
                    ForEach(Array(moodHistory.suffix(7)), id: \.id) { entry in
                        if let score = emotionScale[entry.emotion] {
                            LineMark(
                                x: .value("日期", entry.date),
                                y: .value("情緒值", score)
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle())
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("日期", entry.date),
                                y: .value("情緒值", score)
                            )
                            .annotation(position: .top) {
                                EmojiAnnotationView(emotion: entry.emotion)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let val = value.as(Int.self) {
                                Text(labelForScale(val))
                            }
                        }
                    }
                }
                .padding()
                .frame(height: 280)
            }

            Spacer()
        }
    }

    func labelForScale(_ value: Int) -> String {
        switch value {
        case 5: return "快樂"
        case 4: return "放鬆"
        case 3: return "中性"
        case 2: return "焦慮"
        case 1: return "悲傷"
        default: return ""
        }
    }
}

struct EmojiAnnotationView: View {
    let emotion: String

    var body: some View {
        Text(emojiForEmotion(emotion))
            .font(.title3)
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
}
