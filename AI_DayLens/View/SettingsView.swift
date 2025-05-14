import SwiftUI
import SwiftData

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAlert = false
    @AppStorage("selectedTheme") private var selectedTheme = "light"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("資料管理")) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("🗑 清除所有心情紀錄")
                    }
                }

                Section(header: Text("主題")) {
                    Picker("外觀主題", selection: $selectedTheme) {
                        Text("☀️ 淺色").tag("light")
                        Text("🌙 深色").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

            }
            .navigationTitle("設定")
            .onAppear {
                viewModel.modelContext = modelContext
            }
            .alert("確認要刪除所有紀錄嗎？", isPresented: $showDeleteAlert) {
                Button("刪除", role: .destructive) {
                    viewModel.deleteAllEntries()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("這個操作無法復原，請確認是否真的要清除所有資料。")
            }
        }
    }
}