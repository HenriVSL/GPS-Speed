//
//  ContentView.swift
//  GPS Speed
//
//  The speedometer screen: a large 7-segment current-speed readout as the
//  focal point, a GPS signal indicator up top, and trip stats along the bottom.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject private var location: LocationManager
    @EnvironmentObject private var settings: AppSettings

    @State private var showingSettings = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 0)
                speedReadout
                Spacer(minLength: 0)
                statsBar
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            if location.authorizationStatus == .denied || location.authorizationStatus == .restricted {
                PermissionDeniedOverlay()
            }
        }
        .foregroundStyle(settings.textColor)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            location.requestPermissionAndStart()
            UIApplication.shared.isIdleTimerDisabled = true // keep the screen awake while driving
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: Top bar — GPS signal + settings

    private var topBar: some View {
        HStack {
            GPSSignalView(quality: location.signalQuality, accuracy: location.horizontalAccuracy)
            Spacer()
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
            }
            .accessibilityLabel("Settings")
        }
    }

    // MARK: Center — the main readout

    private var speedReadout: some View {
        VStack(spacing: 4) {
            SpeedReadout(
                value: SpeedFormatter.speedString(metersPerSecond: location.speed, unit: settings.unit),
                option: settings.displayFont,
                color: settings.textColor
            )

            Text(settings.unit.speedLabel)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .opacity(0.7)
        }
    }

    // MARK: Bottom — trip stats

    private var statsBar: some View {
        HStack(alignment: .top, spacing: 12) {
            StatView(
                label: "MAX",
                value: SpeedFormatter.speedString(metersPerSecond: location.maxSpeed, unit: settings.unit),
                unit: settings.unit.speedLabel,
                valueFont: statFont
            )
            StatView(
                label: "AVG",
                value: SpeedFormatter.averageString(metersPerSecond: location.averageSpeed, unit: settings.unit),
                unit: settings.unit.speedLabel,
                valueFont: statFont
            )
            StatView(
                label: "DIST",
                value: SpeedFormatter.distanceString(meters: location.totalDistance, unit: settings.unit),
                unit: settings.unit.distanceLabel,
                valueFont: statFont
            )
        }
    }

    private var statFont: Font {
        settings.displayFont.font(size: 30)
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(AppSettings())
}
