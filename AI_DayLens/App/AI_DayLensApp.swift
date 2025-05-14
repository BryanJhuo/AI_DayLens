//
//  AI_DayLensApp.swift
//  AI_DayLens
//
//  Created by 卓柏辰 on 2025/4/18.
//

import SwiftUI
import SwiftData

@main
struct AI_DayLensApp: App {
    @AppStorage("selectedTheme") var selectedTheme: String = "light"

    var sharedModelContainer: ModelContainer = {
            let schema = Schema([MoodEntry.self])
            let configuration = ModelConfiguration(
                schema: schema,
                url: FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: "group.com.bryanjhuo.AIDayLens")!
                    .appendingPathComponent("daylens.sqlite")
            )
            return try! ModelContainer(for: schema, configurations: [configuration])
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(selectedTheme == "light" ? .light : .dark)
        }
        .modelContainer(sharedModelContainer) // ← 指定 app group
    }
}
