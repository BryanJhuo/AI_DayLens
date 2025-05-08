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
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: MoodEntry.self)
    }
}
