//
//  Story.swift
//  ResonateApp
//
//  A complete multimedia story following Resonate principles
//

import Foundation
import SwiftUI

/// A complete story composed of multiple slides
struct Story: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var author: String
    var createdDate: Date
    var modifiedDate: Date
    var slides: [Slide]
    var template: StoryTemplate?
    var thumbnailPath: String?

    init(
        id: UUID = UUID(),
        title: String = "New Story",
        subtitle: String = "",
        author: String = "",
        createdDate: Date = Date(),
        modifiedDate: Date = Date(),
        slides: [Slide] = [],
        template: StoryTemplate? = nil,
        thumbnailPath: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.author = author
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.slides = slides
        self.template = template
        self.thumbnailPath = thumbnailPath
    }

    // Computed properties
    var slideCount: Int {
        slides.count
    }

    var totalDuration: TimeInterval {
        slides.reduce(0) { $0 + $1.totalDuration }
    }

    var formattedDuration: String {
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    // Story structure analysis
    var narrativeFlow: [SlideRole] {
        slides.map { $0.role }
    }

    var hasBalancedStructure: Bool {
        // Check if story has both "what is" and "what could be" elements
        let roles = Set(narrativeFlow)
        return roles.contains(.whatIs) && roles.contains(.whatCouldBe)
    }
}

// MARK: - Story Templates
enum StoryTemplate: String, Codable, CaseIterable {
    case herosJourney
    case problemSolution
    case beforeAfter
    case custom

    var displayName: String {
        switch self {
        case .herosJourney: return "Hero's Journey"
        case .problemSolution: return "Problem → Solution"
        case .beforeAfter: return "Before → After"
        case .custom: return "Custom"
        }
    }

    var description: String {
        switch self {
        case .herosJourney:
            return "Follow the classic hero's journey structure with call to adventure, trials, and transformation"
        case .problemSolution:
            return "Present a problem, build tension, then reveal the solution"
        case .beforeAfter:
            return "Show the contrast between current state and transformed future"
        case .custom:
            return "Build your story from scratch"
        }
    }

    var defaultSlides: [Slide] {
        switch self {
        case .herosJourney:
            return [
                Slide(title: "The Ordinary World", role: .whatIs, backgroundColor: "#E8E8E8"),
                Slide(title: "Call to Adventure", role: .contrast, backgroundColor: "#FFE5CC"),
                Slide(title: "The Vision", role: .whatCouldBe, backgroundColor: "#E5FFE5"),
                Slide(title: "The Journey", role: .contrast, backgroundColor: "#FFE5CC"),
                Slide(title: "The Transformation", role: .callToAction, backgroundColor: "#E5E5FF"),
                Slide(title: "The New World", role: .resolution, backgroundColor: "#E5F5FF")
            ]
        case .problemSolution:
            return [
                Slide(title: "The Problem", role: .whatIs, backgroundColor: "#FFE5E5"),
                Slide(title: "The Impact", role: .contrast, backgroundColor: "#FFD5D5"),
                Slide(title: "The Solution", role: .whatCouldBe, backgroundColor: "#E5FFE5"),
                Slide(title: "Take Action", role: .callToAction, backgroundColor: "#E5E5FF")
            ]
        case .beforeAfter:
            return [
                Slide(title: "Before: Current State", role: .whatIs, backgroundColor: "#FFE5E5"),
                Slide(title: "The Gap", role: .contrast, backgroundColor: "#FFF5E5"),
                Slide(title: "After: Future State", role: .whatCouldBe, backgroundColor: "#E5FFE5"),
                Slide(title: "Make It Happen", role: .callToAction, backgroundColor: "#E5E5FF")
            ]
        case .custom:
            return [
                Slide(title: "Opening", role: .whatIs, backgroundColor: "#FFFFFF")
            ]
        }
    }
}

// MARK: - Sample Data
extension Story {
    static var sample: Story {
        Story(
            title: "The Power of Story",
            subtitle: "How narratives shape our world",
            author: "Nancy Duarte",
            slides: Slide.sampleSlides,
            template: .herosJourney
        )
    }

    static var samples: [Story] {
        [
            Story(
                title: "The Power of Story",
                subtitle: "How narratives shape our world",
                author: "Demo",
                slides: Slide.sampleSlides,
                template: .herosJourney
            ),
            Story(
                title: "Digital Transformation",
                subtitle: "Leading change in uncertain times",
                author: "Demo",
                slides: StoryTemplate.problemSolution.defaultSlides,
                template: .problemSolution
            ),
            Story(
                title: "Future of Work",
                subtitle: "Embracing remote collaboration",
                author: "Demo",
                slides: StoryTemplate.beforeAfter.defaultSlides,
                template: .beforeAfter
            )
        ]
    }
}
