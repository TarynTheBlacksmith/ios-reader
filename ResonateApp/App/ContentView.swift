//
//  ContentView.swift
//  ResonateApp
//
//  Root view with navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: StoryViewModel
    @State private var selectedStory: Story?
    @State private var showingCreateSheet = false
    @State private var isPresentingStory = false

    var body: some View {
        NavigationStack {
            StoryListView(
                selectedStory: $selectedStory,
                showingCreateSheet: $showingCreateSheet,
                isPresentingStory: $isPresentingStory
            )
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateStoryView()
        }
        .fullScreenCover(item: $selectedStory) { story in
            if isPresentingStory {
                PresentationView(story: story, isPresenting: $isPresentingStory)
            } else {
                StoryEditorView(story: story, isPresenting: .constant(false))
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoryViewModel())
}
