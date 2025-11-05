//
//  MediaElement.swift
//  ResonateApp
//
//  Multimedia elements that can be added to slides
//

import Foundation
import SwiftUI

/// Types of media that can be included in a slide
enum MediaType: String, Codable, CaseIterable {
    case image
    case video
    case audio
    case text

    var icon: String {
        switch self {
        case .image: return "photo"
        case .video: return "video.fill"
        case .audio: return "waveform"
        case .text: return "text.alignleft"
        }
    }
}

/// A media element that can be placed on a slide
struct MediaElement: Identifiable, Codable {
    let id: UUID
    var type: MediaType
    var resourcePath: String?  // Path to media file
    var textContent: String?   // For text elements
    var position: CGPoint      // Position on slide (normalized 0-1)
    var size: CGSize          // Size on slide (normalized 0-1)
    var duration: TimeInterval? // For video/audio playback duration
    var startTime: TimeInterval // When this element appears (in slide timeline)
    var fadeIn: Bool
    var fadeOut: Bool

    // Text styling
    var fontName: String?
    var fontSize: CGFloat?
    var textColor: String?     // Hex color
    var alignment: TextAlignment

    init(
        id: UUID = UUID(),
        type: MediaType,
        resourcePath: String? = nil,
        textContent: String? = nil,
        position: CGPoint = .zero,
        size: CGSize = CGSize(width: 1.0, height: 1.0),
        duration: TimeInterval? = nil,
        startTime: TimeInterval = 0,
        fadeIn: Bool = false,
        fadeOut: Bool = false,
        fontName: String? = nil,
        fontSize: CGFloat? = nil,
        textColor: String? = nil,
        alignment: TextAlignment = .leading
    ) {
        self.id = id
        self.type = type
        self.resourcePath = resourcePath
        self.textContent = textContent
        self.position = position
        self.size = size
        self.duration = duration
        self.startTime = startTime
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        self.fontName = fontName
        self.fontSize = fontSize
        self.textColor = textColor
        self.alignment = alignment
    }
}

enum TextAlignment: String, Codable {
    case leading
    case center
    case trailing

    var swiftUIAlignment: HorizontalAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

// MARK: - Sample Data
extension MediaElement {
    static var sampleImage: MediaElement {
        MediaElement(
            type: .image,
            resourcePath: "sample_image.jpg",
            position: CGPoint(x: 0.1, y: 0.1),
            size: CGSize(width: 0.8, height: 0.6)
        )
    }

    static var sampleText: MediaElement {
        MediaElement(
            type: .text,
            textContent: "The hero's journey begins with a call to adventure",
            position: CGPoint(x: 0.1, y: 0.7),
            size: CGSize(width: 0.8, height: 0.2),
            fontSize: 24,
            alignment: .center
        )
    }
}
