import SwiftUI

struct TrendPagerView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HistoryView(viewModel: viewModel)
                .tag(0)

            TrendChartView(viewModel: viewModel)
                .tag(1)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}