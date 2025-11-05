//
//  SlideRenderer.swift
//  ResonateApp
//
//  Renders a slide with all its media elements
//

import SwiftUI
import AVFoundation

struct SlideRenderer: View {
    let slide: Slide
    let isVisible: Bool

    @State private var visibleElements: Set<UUID> = []
    @State private var animationTrigger = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundView
                    .ignoresSafeArea()

                // Media elements
                ForEach(slide.mediaElements) { element in
                    MediaElementRenderer(
                        element: element,
                        isVisible: visibleElements.contains(element.id),
                        containerSize: geometry.size
                    )
                }
            }
        }
        .onAppear {
            animateElementsIn()
        }
        .onChange(of: isVisible) { _, newValue in
            if newValue {
                animateElementsIn()
            } else {
                visibleElements.removeAll()
            }
        }
    }

    private var backgroundView: some View {
        Group {
            if let backgroundImage = slide.backgroundImage {
                // In production, load actual image
                hexToColor(slide.backgroundColor)
            } else {
                hexToColor(slide.backgroundColor)
            }
        }
    }

    private func animateElementsIn() {
        visibleElements.removeAll()

        // Sort elements by start time
        let sortedElements = slide.mediaElements.sorted { $0.startTime < $1.startTime }

        // Animate each element at its start time
        for element in sortedElements {
            let delay = element.startTime

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(element.fadeIn ? .easeIn(duration: 0.5) : .none) {
                    _ = visibleElements.insert(element.id)
                }
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
            (r, g, b) = (0, 0, 0)
        }
        return Color(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

// MARK: - Media Element Renderer

struct MediaElementRenderer: View {
    let element: MediaElement
    let isVisible: Bool
    let containerSize: CGSize

    var body: some View {
        let xPos = element.position.x * containerSize.width
        let yPos = element.position.y * containerSize.height
        let width = element.size.width * containerSize.width
        let height = element.size.height * containerSize.height

        Group {
            switch element.type {
            case .text:
                textView
                    .frame(width: width, height: height)

            case .image:
                imageView
                    .frame(width: width, height: height)

            case .video:
                videoView
                    .frame(width: width, height: height)

            case .audio:
                audioView
                    .frame(width: width, height: height)
            }
        }
        .position(x: xPos + width / 2, y: yPos + height / 2)
        .opacity(isVisible ? 1 : 0)
    }

    @ViewBuilder
    private var textView: some View {
        if let text = element.textContent {
            Text(text)
                .font(.system(size: element.fontSize ?? 24, weight: .semibold))
                .foregroundColor(hexToColor(element.textColor ?? "#FFFFFF"))
                .multilineTextAlignment(
                    element.alignment == .leading ? .leading :
                    element.alignment == .center ? .center : .trailing
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                .padding()
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let resourcePath = element.resourcePath {
            // In production, load actual image from path
            AsyncImage(url: URL(string: resourcePath)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure, .empty:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.2))

            Image(systemName: "photo")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    @ViewBuilder
    private var videoView: some View {
        if let resourcePath = element.resourcePath {
            // In production, use AVPlayer to play video
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black)

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.8))
            }
        } else {
            placeholderVideo
        }
    }

    private var placeholderVideo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.2))

            Image(systemName: "video.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    @ViewBuilder
    private var audioView: some View {
        // Audio is typically invisible or shows a waveform visualization
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))

            VStack(spacing: 8) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 40))

                if let duration = element.duration {
                    Text(String(format: "%.1fs", duration))
                        .font(.caption)
                }
            }
            .foregroundStyle(.white.opacity(0.8))
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
            (r, g, b) = (255, 255, 255)
        }
        return Color(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

#Preview {
    SlideRenderer(slide: .sample, isVisible: true)
        .background(Color.black)
}
