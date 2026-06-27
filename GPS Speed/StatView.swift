//
//  StatView.swift
//  GPS Speed
//
//  One labelled trip stat (MAX / AVG / DIST). The number uses the 7-segment
//  font to match the main readout; the label and unit use the system font
//  since DSEG has no proper letterforms.
//

import SwiftUI

struct StatView: View {
    let label: String
    let value: String
    let unit: String
    /// The user-selected display font, sized for stats.
    let valueFont: Font

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .opacity(0.6)

            Text(value)
                .font(valueFont)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .monospacedDigit()

            Text(unit)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .opacity(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}
