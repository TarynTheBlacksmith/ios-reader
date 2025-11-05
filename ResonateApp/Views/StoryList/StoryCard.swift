//
//  StoryCard.swift
//  ResonateApp
//
//  Card displaying story preview
//

import SwiftUI

struct StoryCard: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail
            thumbnailView
                .frame(height: 200)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Title and info
            VStack(alignment: .leading, spacing: 6) {
                Text(story.title)
                    .font(.headline)
                    .lineLimit(2)

                if !story.subtitle.isEmpty {
                    Text(story.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack {
                    Label("\(story.slideCount)", systemImage: "square.stack.3d.up")
                    Spacer()
                    Label(story.formattedDuration, systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                // Template badge
                if let template = story.template {
                    Text(template.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
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
