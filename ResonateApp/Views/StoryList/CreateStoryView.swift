//
//  CreateStoryView.swift
//  ResonateApp
//
//  Sheet for creating a new story
//

import SwiftUI

struct CreateStoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: StoryViewModel

    @State private var title = ""
    @State private var selectedTemplate: StoryTemplate = .herosJourney

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Story Title", text: $title)
                        .font(.title3)
                } header: {
                    Text("Title")
                }

                Section {
                    ForEach(StoryTemplate.allCases, id: \.self) { template in
                        templateRow(template)
                    }
                } header: {
                    Text("Choose a Template")
                } footer: {
                    Text(selectedTemplate.description)
                        .font(.footnote)
                }
            }
            .navigationTitle("New Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createStory()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func templateRow(_ template: StoryTemplate) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.displayName)
                    .font(.headline)

                Text("\(template.defaultSlides.count) slides")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if selectedTemplate == template {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTemplate = template
        }
    }

    private func createStory() {
        let storyTitle = title.isEmpty ? "Untitled Story" : title
        viewModel.createStory(title: storyTitle, template: selectedTemplate)
        dismiss()
    }
}

#Preview {
    CreateStoryView()
        .environmentObject(StoryViewModel())
}
