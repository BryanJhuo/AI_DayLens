import WidgetKit
import SwiftData
import SwiftUI

struct MoodWidgetEntry: TimelineEntry {
    let date: Date
    let mood: MoodEntry?
    let recentHistory: [MoodEntry]? 
}

struct MoodTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoodWidgetEntry {
        MoodWidgetEntry(date: Date(), mood: nil, recentHistory: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (MoodWidgetEntry) -> Void) {
        Task {
            let mood = await fetchTodayMood()
            completion(MoodWidgetEntry(date: Date(), mood: mood, recentHistory: nil))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodWidgetEntry>) -> Void) {
        Task {
            let mood = await fetchTodayMood()
            let history = await fetchRecentHistory()
            let entry = MoodWidgetEntry(date: Date(), mood: mood, recentHistory: Array(history))

            completion(Timeline(entries: [entry], policy: .after(.now.advanced(by: 3600))))
        }
    }

    func fetchTodayMood() async -> MoodEntry? {
        do {
            let schema = Schema([MoodEntry.self])
            guard let appGroupURL = FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: "group.com.bryanjhuo.AIDayLens") else {
                print("❌ App Group URL 無法取得，請確認 App Group ID 正確")
                return nil
            }

            let url = appGroupURL.appendingPathComponent("daylens.sqlite")
            let config = ModelConfiguration(schema: schema, url: url)

            let container = try ModelContainer(for: schema, configurations: [config])
            let context = ModelContext(container)


            let calendar = Calendar.current
            let start = calendar.startOfDay(for: Date())
            let end = calendar.date(byAdding: .day, value: 1, to: start)!

            let descriptor = FetchDescriptor<MoodEntry>(
                predicate: #Predicate {
                    $0.date >= start && $0.date < end
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )

            return try context.fetch(descriptor).first
        } catch {
            print("❌ Widget fetch error: \(error)")
            return nil
        }
    }

    func fetchRecentHistory() async -> [MoodEntry] {
        do {
            let context = try buildModelContext()

            let descriptor = FetchDescriptor<MoodEntry>(
                predicate: nil,
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )

            return Array(try context.fetch(descriptor).suffix(7))
        } catch {
            print("❌ fetchRecentHistory failed: \(error)")
            return []
        }
    }

    private func buildModelContext() throws -> ModelContext {
        let schema = Schema([MoodEntry.self])
        guard let appGroupURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.bryanjhuo.AIDayLens") else {
            throw NSError(domain: "Widget", code: 1, userInfo: [NSLocalizedDescriptionKey: "App Group URL 無法取得"])
        }

        let url = appGroupURL.appendingPathComponent("daylens.sqlite")
        let config = ModelConfiguration(schema: schema, url: url)

        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }


}
