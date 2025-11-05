//
//  StoryListView.swift
//  ResonateApp
//
//  List of all stories
//

import SwiftUI

struct StoryListView: View {
    @EnvironmentObject var viewModel: StoryViewModel
    @Binding var selectedStory: Story?
    @Binding var showingCreateSheet: Bool
    @Binding var isPresentingStory: Bool

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading stories...")
            } else if viewModel.stories.isEmpty {
                emptyState
            } else {
                storyGrid
            }
        }
        .navigationTitle("Resonate")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Label("New Story", systemImage: "plus")
                }
            }
        }
    }

    private var storyGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
            ], spacing: 20) {
                ForEach(viewModel.stories) { story in
                    StoryCard(story: story)
                        .onTapGesture {
                            isPresentingStory = false
                            selectedStory = story
                        }
                        .contextMenu {
                            Button {
                                isPresentingStory = true
                                selectedStory = story
                            } label: {
                                Label("Present", systemImage: "play.fill")
                            }

                            Button {
                                isPresentingStory = false
                                selectedStory = story
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Divider()

                            Button {
                                viewModel.duplicateStory(story)
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }

                            Button(role: .destructive) {
                                viewModel.deleteStory(story)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.pages")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Stories Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create your first multimedia story\nfollowing Resonate principles")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                showingCreateSheet = true
            } label: {
                Label("Create Story", systemImage: "plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        StoryListView(
            selectedStory: .constant(nil),
            showingCreateSheet: .constant(false),
            isPresentingStory: .constant(false)
        )
        .environmentObject(StoryViewModel())
    }
}
