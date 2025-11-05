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
            LazyVGrid(columns: Layout.gridColumns, spacing: Layout.gridSpacing) {
                ForEach(viewModel.stories) { story in
                    StoryCard(
                        story: story,
                        onEdit: {
                            isPresentingStory = false
                            selectedStory = story
                        },
                        onPresent: {
                            isPresentingStory = true
                            selectedStory = story
                        }
                    )
                    .contextMenu {
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
            .padding(Spacing.screenPadding)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.large) {
            Image(systemName: "book.pages")
                .font(.system(size: 72))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.top, Spacing.xxxLarge)

            VStack(spacing: Spacing.small) {
                Text("No Stories Yet")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Create your first multimedia story\nfollowing Resonate principles")
                    .font(AppFonts.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Button {
                showingCreateSheet = true
            } label: {
                Label("Create Story", systemImage: "plus")
                    .font(AppFonts.bodyEmphasis)
            }
            .primaryButtonStyle()
            .padding(.top, Spacing.small)
        }
        .padding(Spacing.screenPadding)
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
