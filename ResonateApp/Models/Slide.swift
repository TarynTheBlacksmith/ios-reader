//
//  Slide.swift
//  ResonateApp
//
//  Individual slide in a story
//

import Foundation
import SwiftUI

/// The narrative role of a slide in the story structure
enum SlideRole: String, Codable, CaseIterable {
    case whatIs          // Current state/problem
    case whatCouldBe     // Desired future state
    case contrast        // Highlighting the gap
    case callToAction    // Inspiring change
    case resolution      // The transformed future

    var color: Color {
        switch self {
        case .whatIs: return AppColors.whatIs
        case .whatCouldBe: return AppColors.whatCouldBe
        case .contrast: return AppColors.contrast
        case .callToAction: return AppColors.callToAction
        case .resolution: return AppColors.resolution
        }
    }

    var description: String {
        switch self {
        case .whatIs: return "Current State"
        case .whatCouldBe: return "Desired Future"
        case .contrast: return "The Gap"
        case .callToAction: return "Call to Action"
        case .resolution: return "Resolution"
        }
    }
}

/// Transition style between slides
enum TransitionStyle: String, Codable, CaseIterable {
    case fade
    case slide
    case zoom
    case dissolve

    var displayName: String {
        rawValue.capitalized
    }
}

/// Individual slide containing multimedia elements
struct Slide: Identifiable, Codable {
    let id: UUID
    var title: String
    var role: SlideRole
    var backgroundColor: String  // Hex color
    var backgroundImage: String? // Path to background image
    var mediaElements: [MediaElement]
    var duration: TimeInterval   // How long slide displays (0 = manual advance)
    var transition: TransitionStyle
    var notes: String           // Speaker notes / guidance

    init(
        id: UUID = UUID(),
        title: String = "Untitled Slide",
        role: SlideRole = .whatIs,
        backgroundColor: String = "#FFFFFF",
        backgroundImage: String? = nil,
        mediaElements: [MediaElement] = [],
        duration: TimeInterval = 0,
        transition: TransitionStyle = .fade,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.role = role
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.mediaElements = mediaElements
        self.duration = duration
        self.transition = transition
        self.notes = notes
    }

    // Computed properties
    var hasAutoAdvance: Bool {
        duration > 0
    }

    var totalDuration: TimeInterval {
        // Calculate total duration including all media elements
        let mediaDuration = mediaElements.compactMap { $0.duration }.max() ?? 0
        return max(duration, mediaDuration)
    }
}

// MARK: - Sample Data
extension Slide {
    static var sample: Slide {
        Slide(
            title: "The Journey Begins",
            role: .whatIs,
            backgroundColor: "#F5F5F5",
            mediaElements: [
                MediaElement.sampleImage,
                MediaElement.sampleText
            ],
            duration: 5.0,
            notes: "Introduce the current state and set the scene"
        )
    }

    static var sampleSlides: [Slide] {
        [
            Slide(
                title: "Current Reality",
                role: .whatIs,
                backgroundColor: "#FFE5E5",
                mediaElements: [
                    MediaElement(
                        type: .text,
                        textContent: "Where we are today",
                        position: CGPoint(x: 0.1, y: 0.4),
                        size: CGSize(width: 0.8, height: 0.2),
                        fontSize: 48,
                        alignment: .center
                    )
                ],
                duration: 3.0
            ),
            Slide(
                title: "Desired Future",
                role: .whatCouldBe,
                backgroundColor: "#E5FFE5",
                mediaElements: [
                    MediaElement(
                        type: .text,
                        textContent: "Where we could be",
                        position: CGPoint(x: 0.1, y: 0.4),
                        size: CGSize(width: 0.8, height: 0.2),
                        fontSize: 48,
                        alignment: .center
                    )
                ],
                duration: 3.0
            ),
            Slide(
                title: "Take Action",
                role: .callToAction,
                backgroundColor: "#E5E5FF",
                mediaElements: [
                    MediaElement(
                        type: .text,
                        textContent: "The time to act is now",
                        position: CGPoint(x: 0.1, y: 0.4),
                        size: CGSize(width: 0.8, height: 0.2),
                        fontSize: 48,
                        alignment: .center
                    )
                ],
                duration: 3.0
            )
        ]
    }
}
