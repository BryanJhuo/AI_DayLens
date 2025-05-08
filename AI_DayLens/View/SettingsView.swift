import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack {
            Text("設定畫面")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
    }
}