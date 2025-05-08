import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        TabView {
            MainView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("首頁")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("歷史紀錄")
                }
                
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
        }
    }
}

#Preview {
    MainTabView()
}
