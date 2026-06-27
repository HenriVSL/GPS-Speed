//
//  SettingsView.swift
//  GPS Speed
//
//  Lets the user pick the readout color and units, and reset the trip. All
//  changes are in-memory only (no persistence by design).
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var location: LocationManager
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Picker("Speed", selection: $settings.unit) {
                        Text("km/h").tag(SpeedUnit.kmh)
                        Text("mph").tag(SpeedUnit.mph)
                    }
                    .pickerStyle(.segmented)
                }

                fontSection

                Section("Text Color") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(AppSettings.presetColors.enumerated()), id: \.offset) { _, color in
                            swatch(color)
                        }
                    }
                    .padding(.vertical, 4)

                    ColorPicker("Custom", selection: $settings.textColor, supportsOpacity: false)
                }

                Section {
                    Button(role: .destructive) {
                        location.resetTrip()
                    } label: {
                        Label("Reset Trip", systemImage: "arrow.counterclockwise")
                    }
                } footer: {
                    Text("Clears max, average, and distance. Stats also reset when the app is relaunched.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: Font selection

    @ViewBuilder
    private var fontSection: some View {
        let options = FontLibrary.shared.options
        Section("Display Font") {
            ForEach(options) { option in
                fontRow(option, label: label(for: option))
            }
        }

        if options.count <= 1 {
            // Only the system font is available — no custom fonts bundled yet.
            Section {
                Text("Add .ttf or .otf font files to the app target to choose more fonts here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// When every custom font is the same family (e.g. just DSEG7 Classic), show
    /// only the style — "Regular", "Bold", … — otherwise the full name.
    private func label(for option: FontOption) -> String {
        guard option.category != .system else { return "System" }
        let families = Set(FontLibrary.shared.customOptions.map(\.familyName))
        if families.count == 1 {
            return option.styleName.isEmpty ? "Regular" : option.styleName
        }
        return option.displayName
    }

    private func fontRow(_ option: FontOption, label: String) -> some View {
        Button {
            settings.fontID = option.id
        } label: {
            HStack(spacing: 12) {
                Text(label)
                    .foregroundStyle(.primary)
                Spacer()
                Text("123")
                    .font(option.font(size: 26))
                    .foregroundStyle(.secondary)
                if settings.fontID == option.id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func swatch(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(height: 36)
            .overlay {
                Circle()
                    .strokeBorder(.primary, lineWidth: settings.textColor == color ? 3 : 0)
            }
            .overlay {
                if settings.textColor == color {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color == .white ? .black : .white)
                }
            }
            .onTapGesture {
                settings.textColor = color
            }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
        .environmentObject(LocationManager())
}
