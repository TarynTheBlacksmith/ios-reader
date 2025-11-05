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
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    // Title section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Story Title")
                            .font(AppFonts.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.textSecondary)

                        TextField("Enter title...", text: $title)
                            .font(AppFonts.title3)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                    }

                    Divider()

                    // Template selection
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        Text("Choose a Template")
                            .font(AppFonts.headline)
                            .foregroundStyle(AppColors.textPrimary)

                        VStack(spacing: Spacing.medium) {
                            ForEach(StoryTemplate.allCases, id: \.self) { template in
                                templateCard(template)
                            }
                        }
                    }
                }
                .padding(Spacing.large)
            }
            .background(AppColors.groupedBackground)
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
                    .primaryButtonStyle()
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func templateCard(_ template: StoryTemplate) -> some View {
        let isSelected = selectedTemplate == template

        return VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Text(template.displayName)
                        .font(AppFonts.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("\(template.defaultSlides.count) slides")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? AppColors.primary : AppColors.textSecondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }

            Text(template.description)
                .font(AppFonts.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            // Visual preview of narrative flow
            narrativeFlowPreview(template: template)
        }
        .padding(Spacing.medium)
        .background(isSelected ? AppColors.primary.opacity(0.08) : AppColors.background)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .strokeBorder(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(AppAnimations.quick) {
                selectedTemplate = template
            }
        }
    }

    private func narrativeFlowPreview(template: StoryTemplate) -> some View {
        HStack(spacing: Spacing.xxSmall) {
            ForEach(Array(template.defaultSlides.enumerated()), id: \.offset) { index, slide in
                RoundedRectangle(cornerRadius: 3)
                    .fill(slide.role.color)
                    .frame(width: 28, height: 20)
                    .overlay(
                        Text("\(index + 1)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
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
