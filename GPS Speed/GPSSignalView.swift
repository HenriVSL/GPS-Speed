//
//  GPSSignalView.swift
//  GPS Speed
//
//  Compact GPS signal indicator: four bars colored by quality, a text label,
//  and the raw horizontal accuracy in meters. Uses the quality's own color
//  (not the user's text color) so red/orange stay meaningful.
//

import SwiftUI
import CoreLocation

struct GPSSignalView: View {
    let quality: GPSSignalQuality
    let accuracy: CLLocationAccuracy

    var body: some View {
        HStack(spacing: 8) {
            bars
            VStack(alignment: .leading, spacing: 1) {
                Text(quality.label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                Text(accuracyText)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .opacity(0.6)
            }
        }
        .foregroundStyle(quality.color)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("GPS signal \(quality.label), \(accuracyText)")
    }

    private var bars: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < quality.bars ? quality.color : quality.color.opacity(0.2))
                    .frame(width: 4, height: 6 + CGFloat(index) * 4)
            }
        }
    }

    private var accuracyText: String {
        accuracy >= 0 ? "±\(Int(accuracy.rounded())) m" : "—"
    }
}
