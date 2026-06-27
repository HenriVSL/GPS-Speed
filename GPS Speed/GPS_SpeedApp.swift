//
//  GPS_SpeedApp.swift
//  GPS Speed
//
//  Created by Henri Lavikainen on 27.6.2026.
//

import SwiftUI

@main
struct GPS_SpeedApp: App {
    @StateObject private var location = LocationManager()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(location)
                .environmentObject(settings)
                .preferredColorScheme(.dark)
        }
    }
}
