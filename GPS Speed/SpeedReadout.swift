//
//  SpeedReadout.swift
//  GPS Speed
//
//  The big current-speed number. For segment fonts (DSEG) it mimics a real
//  display: every digit slot shows all segments faintly lit ("off" segments),
//  with the live value drawn bright on top — so behind a bright 6 you can still
//  see the segments that would complete an 8. Two layers are used:
//    • back  — "888" in a dim tint of the chosen color (the off segments)
//    • front — the value, left-padded with *clear* 8s so both layers render the
//              same monospaced glyphs and therefore scale/align identically.
//  Digit slots are fixed so the number never shifts, and there's no rolling
//  animation — a segment display just lights different segments in place.
//

import SwiftUI

struct SpeedReadout: View {
    /// Already-formatted value, e.g. "65".
    let value: String
    let option: FontOption
    let color: Color

    /// Digit positions to reserve so the number never shifts (handles up to 999).
    var slots: Int = 3
    var size: CGFloat = 140

    var body: some View {
        content
            .font(option.font(size: size))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.5) // both layers share glyph widths → scale together
    }

    @ViewBuilder
    private var content: some View {
        if option.isSegmented {
            // Number of slots actually shown (never fewer than the value needs).
            let slotCount = max(slots, value.count)
            ZStack {
                Text(offSegments(count: slotCount))   // faint, all segments lit
                Text(litValue(slots: slotCount))       // bright value on top
            }
        } else {
            // Non-segment fonts (System/Arcade) have no "off segment" concept.
            Text(value).foregroundStyle(color)
        }
    }

    /// The dim background: every slot shows a full "8".
    private func offSegments(count: Int) -> AttributedString {
        var s = AttributedString(String(repeating: "8", count: count))
        s.foregroundColor = color.opacity(0.09) // half the previous dimness
        return s
    }

    /// The bright value, left-padded with *clear* 8s so this layer renders the
    /// exact same glyphs (and width) as the off-segment layer.
    private func litValue(slots: Int) -> AttributedString {
        var result = AttributedString()

        let padding = slots - value.count
        if padding > 0 {
            var pad = AttributedString(String(repeating: "8", count: padding))
            pad.foregroundColor = .clear
            result += pad
        }

        var on = AttributedString(value)
        on.foregroundColor = color
        result += on

        return result
    }
}
