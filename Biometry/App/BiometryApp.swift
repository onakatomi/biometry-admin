//
//  BiometryApp.swift
//  Biometry
//
//  Created by Nakatomi on 15/7/2025.
//

import SwiftUI

@main
struct BiometryApp: App {
    @StateObject private var viewModel = VideoPlaybackViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
