//
//  MainViewModel.swift
//  AI_DayLens
//
//  Created by 卓柏辰 on 2025/4/23.
//

import Foundation
import SwiftUI
import SwiftData
import WidgetKit

class MainViewModel: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = "light"
    @Published var userInput : String = ""
    @Published var emotion : String? = nil
    @Published var message : String? = nil
    @Published var isLoading : Bool = false
    @Published var selectedModel : String = LLMModel.deepseekV3.rawValue
    @Published var selectedDate: Date = Date()
    @Published var temperature: String = "讀取中..."

    @Published var showOverwriteAlert: Bool = false
    var modelContext: ModelContext?
    private var pendingEntry: MoodEntry? = nil


    private let llmService = LLMService()

    var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: selectedDate)
    }

    func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: Date())
    }

    func dayBounds(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return (start: startOfDay, end: endOfDay)
    }
    
    func analyzeInput() {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            do {
                let result = try await llmService.analyzeEmotion(input: userInput, model: selectedModel)
                DispatchQueue.main.async {
                    self.emotion = result.emotion
                    self.message = result.message
                    self.isLoading = false
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.emotion = "❌ 分析失敗"
                    self.message = "\(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    func saveTodayEntry() {
        guard let modelContext else { 
            print("❌ modelContext is nil, cannot save.")
            return 
        }

        guard let emotion, let message else {
            print("❌ Emotion or message is nil, cannot save.")
            return
        }

        let todayKey = MoodEntry.formatDate(selectedDate)

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate {
                $0.dayString == todayKey
            }
        )

        do {
            if let existing = try? modelContext.fetch(descriptor).first {
                pendingEntry = MoodEntry(date: selectedDate, userInput: userInput, emotion: emotion, message: message)
                showOverwriteAlert = true
            } else {
                let newEntry = MoodEntry(date: selectedDate, userInput: userInput, emotion: emotion, message: message)
                do {
                    try modelContext.insert(newEntry)
                    try modelContext.save()
                    print("✅ Entry saved successfully.")
                    clearAfterSave()
                } catch {
                    print("Failed to save entry: \(error)")
                }
            }
        }  catch {
            print("Failed to fetch existing entry: \(error)")
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "AI_DayLensWidget")
    }

    func confirmOverwrite() {
        guard let modelContext, let pending = pendingEntry else { return }

        let todayKey = MoodEntry.formatDate(pending.date)

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate {
                $0.dayString == todayKey
            }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
        }

        modelContext.insert(pending)
        
        do {
            try modelContext.save()
            print("✅ Entry overwritten successfully.")
            clearAfterSave()
        } catch {
            print("Failed to overwrite entry: \(error)")
        }
    }

    private func clearAfterSave() {
        userInput = ""
        emotion = nil
        message = nil
        showOverwriteAlert = false
        pendingEntry = nil
    }

    func emojiForEmotion() -> String {
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

    func deleteEntry(_ entry: MoodEntry) {
        guard let modelContext else {
            print("❌ modelContext is nil")
            return
        }

        modelContext.delete(entry)
        do {
            try modelContext.save()
            print("✅ Entry deleted: \(entry.date)")
        } catch {
            print("❌ Failed to delete entry: \(error)")
        }
    }

    func deleteAllEntries() {
        guard let modelContext else {
            print("❌ modelContext is nil, cannot delete.")
            return
        }

        let descriptor = FetchDescriptor<MoodEntry>()
        do {
            let entries = try modelContext.fetch(descriptor)
            for entry in entries {
                modelContext.delete(entry)
            }
            try modelContext.save()
            print("✅ All entries deleted successfully.")
        } catch {
            print("Failed to delete entries: \(error)")
        }
    }
}

func emojiForEmotionText(_ emotion: String) -> String {
    switch emotion {
    case "快樂": return "😄"
    case "悲傷": return "😢"
    case "焦慮": return "😰"
    case "放鬆": return "🧘"
    case "中性": return "😐"
    default: return "🤔"
    }
}
