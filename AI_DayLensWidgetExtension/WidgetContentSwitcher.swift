import WidgetKit
import SwiftUI

struct WidgetContentSwitcher: View {
    let entry: MoodWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            MoodWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            Text("不支援的尺寸")
        }
    }
}
