//
//  ResonateApp.swift
//  ResonateApp
//
//  Main app entry point
//

import SwiftUI

@main
struct ResonateApp: App {
    @StateObject private var storyViewModel = StoryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storyViewModel)
        }
    }
}
