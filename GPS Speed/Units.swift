//
//  Units.swift
//  GPS Speed
//
//  Speed/distance unit handling. CoreLocation gives us metric base units
//  (speed in m/s, distance in meters); everything user-facing converts here.
//

import Foundation

enum SpeedUnit: String, CaseIterable, Identifiable {
    case kmh
    case mph

    var id: String { rawValue }

    /// Short label shown under the speed readout, e.g. "km/h".
    var speedLabel: String {
        switch self {
        case .kmh: "km/h"
        case .mph: "mph"
        }
    }

    /// Short label for accumulated distance, e.g. "km".
    var distanceLabel: String {
        switch self {
        case .kmh: "km"
        case .mph: "mi"
        }
    }

    /// Convert a speed in meters/second to this unit.
    func speed(fromMetersPerSecond mps: Double) -> Double {
        switch self {
        case .kmh: mps * 3.6
        case .mph: mps * 2.236936292054402
        }
    }

    /// Convert a distance in meters to this unit's large distance unit (km or mi).
    func distance(fromMeters meters: Double) -> Double {
        switch self {
        case .kmh: meters / 1000.0
        case .mph: meters / 1609.344
        }
    }
}

enum SpeedFormatter {
    /// Current/max speed: whole numbers, like a real speedometer.
    static func speedString(metersPerSecond mps: Double, unit: SpeedUnit) -> String {
        let value = max(0, unit.speed(fromMetersPerSecond: mps))
        return String(Int(value.rounded()))
    }

    /// Average speed: one decimal so small trips still read meaningfully.
    static func averageString(metersPerSecond mps: Double, unit: SpeedUnit) -> String {
        let value = max(0, unit.speed(fromMetersPerSecond: mps))
        return String(format: "%.1f", value)
    }

    /// Distance: two decimals under 10, one decimal above.
    static func distanceString(meters: Double, unit: SpeedUnit) -> String {
        let value = max(0, unit.distance(fromMeters: meters))
        return value < 10
            ? String(format: "%.2f", value)
            : String(format: "%.1f", value)
    }
}
