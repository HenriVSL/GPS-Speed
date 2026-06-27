//
//  GPSSignalQuality.swift
//  GPS Speed
//
//  Maps a fix's horizontal accuracy (in meters) onto a human-readable signal
//  quality, used for the on-screen GPS indicator.
//

import SwiftUI
import CoreLocation

enum GPSSignalQuality: Int, CaseIterable {
    case none = 0   // no valid fix
    case poor
    case weak
    case fair
    case good
    case excellent

    init(accuracy: CLLocationAccuracy) {
        switch accuracy {
        case ..<0:      self = .none
        case 0...5:     self = .excellent
        case 5...10:    self = .good
        case 10...20:   self = .fair
        case 20...50:   self = .weak
        default:        self = .poor
        }
    }

    var label: String {
        switch self {
        case .none:      "No Signal"
        case .poor:      "Poor"
        case .weak:      "Weak"
        case .fair:      "Fair"
        case .good:      "Good"
        case .excellent: "Excellent"
        }
    }

    /// Number of filled bars (0–4) for the indicator.
    var bars: Int {
        switch self {
        case .none:      0
        case .poor:      1
        case .weak:      2
        case .fair:      3
        case .good, .excellent: 4
        }
    }

    var color: Color {
        switch self {
        case .none:      .gray
        case .poor:      .red
        case .weak:      .orange
        case .fair:      .yellow
        case .good, .excellent: .green
        }
    }
}
