//
//  AI_DayLensWidgetExtension.swift
//  AI_DayLensWidgetExtension
//
//  Created by 卓柏辰 on 2025/5/11.
//

import WidgetKit
import SwiftUI

@main
struct AI_DayLensWidget: Widget {
    let kind: String = "AI_DayLensWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoodTimelineProvider()) { entry in
            WidgetContentSwitcher(entry: entry)
        }
    }
}

