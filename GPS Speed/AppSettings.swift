//
//  AppSettings.swift
//  GPS Speed
//
//  In-memory user preferences. Per the app's "no storage" design these reset
//  on every launch — there's no UserDefaults/persistence by intent.
//

import SwiftUI
import Combine

@MainActor
final class AppSettings: ObservableObject {
    /// Color of the speed readout and stats. Black background is fixed.
    @Published var textColor: Color = .green

    @Published var unit: SpeedUnit = .kmh

    /// Selected display font (id of a `FontOption`). Defaults to a DSEG font if
    /// one is bundled, otherwise the system font.
    @Published var fontID: String = FontLibrary.shared.defaultOption.id

    /// The resolved display font for the current selection.
    var displayFont: FontOption {
        FontLibrary.shared.option(for: fontID)
    }

    /// Quick-pick palette shown in settings, alongside a full ColorPicker.
    static let presetColors: [Color] = [
        .green, .red, .orange, .yellow, .cyan, .blue, .purple, .white
    ]
}
