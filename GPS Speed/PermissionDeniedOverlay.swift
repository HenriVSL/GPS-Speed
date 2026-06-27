//
//  PermissionDeniedOverlay.swift
//  GPS Speed
//
//  Shown when location access is denied/restricted. The app is useless without
//  a fix, so this covers the screen and routes the user to Settings.
//

import SwiftUI

struct PermissionDeniedOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 48))
                Text("Location Access Needed")
                    .font(.title2.weight(.semibold))
                Text("GPS Speed needs your location to show your speed. Enable it in Settings.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .opacity(0.8)

                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .foregroundStyle(.white)
            .padding(32)
        }
    }
}
