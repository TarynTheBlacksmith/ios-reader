//
//  StoryCard.swift
//  ResonateApp
//
//  Card displaying story preview
//

import SwiftUI

struct StoryCard: View {
    let story: Story
    @State private var isHovered = false

    var onEdit: () -> Void = {}
    var onPresent: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail with action buttons overlay
            ZStack(alignment: .bottom) {
                thumbnailView
                    .frame(height: 220)
                    .background(AppColors.tertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card, corners: [.topLeft, .topRight]))

                // Action buttons overlay
                actionButtons
                    .padding(Spacing.medium)
            }

            // Title and info
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(story.title)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .frame(minHeight: 44, alignment: .topLeading)

                if !story.subtitle.isEmpty {
                    Text(story.subtitle)
                        .font(AppFonts.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .frame(minHeight: 36, alignment: .topLeading)
                }

                Spacer(minLength: Spacing.xSmall)

                // Metadata row
                HStack(spacing: Spacing.medium) {
                    Label("\(story.slideCount)", systemImage: "square.stack.3d.up")
                        .font(AppFonts.footnote)

                    Label(story.formattedDuration, systemImage: "clock")
                        .font(AppFonts.footnote)

                    Spacer()

                    // Template badge
                    if let template = story.template {
                        Text(template.displayName)
                            .font(AppFonts.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, Spacing.xSmall)
                            .padding(.vertical, Spacing.xxSmall)
                            .background(AppColors.primary.opacity(0.15))
                            .foregroundStyle(AppColors.primary)
                            .clipShape(Capsule())
                    }
                }
                .foregroundStyle(AppColors.textSecondary)
            }
            .padding(Spacing.medium)
        }
        .cardStyle(elevation: isHovered ? 2 : 1)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(AppAnimations.quick, value: isHovered)
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.small) {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
                    .font(AppFonts.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.small)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }

            Button {
                onPresent()
            } label: {
                Label("Present", systemImage: "play.fill")
                    .font(AppFonts.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.small)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnailPath = story.thumbnailPath {
            // In production, load actual image
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let firstSlide = story.slides.first {
            // Generate thumbnail from first slide
            slidePreview(firstSlide)
        } else {
            // Placeholder
            Image(systemName: "photo.stack")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func slidePreview(_ slide: Slide) -> some View {
        ZStack {
            // Background color
            hexToColor(slide.backgroundColor)

            // First text element as preview
            if let firstText = slide.mediaElements.first(where: { $0.type == .text }) {
                Text(firstText.textContent ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .lineLimit(3)
            }
        }
    }

    private func hexToColor(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (128, 128, 128)
        }
        return Color(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

#Preview {
    StoryCard(story: .sample)
        .frame(width: 350)
        .padding()
}
