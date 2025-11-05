//
//  StoryViewModel.swift
//  ResonateApp
//
//  Manages story creation, editing, and persistence
//

import Foundation
import SwiftUI
import Combine

@MainActor
class StoryViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var selectedStory: Story?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadStories()
    }

    // MARK: - Story Management

    func loadStories() {
        isLoading = true
        // In production, this would load from persistent storage
        // For now, load sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.stories = Story.samples
            self?.isLoading = false
        }
    }

    func createStory(title: String, template: StoryTemplate) {
        let newStory = Story(
            title: title,
            subtitle: "",
            author: "User",
            slides: template.defaultSlides,
            template: template
        )
        stories.insert(newStory, at: 0)
        selectedStory = newStory
        saveStory(newStory)
    }

    func updateStory(_ story: Story) {
        if let index = stories.firstIndex(where: { $0.id == story.id }) {
            var updatedStory = story
            updatedStory.modifiedDate = Date()
            stories[index] = updatedStory
            selectedStory = updatedStory
            saveStory(updatedStory)
        }
    }

    func deleteStory(_ story: Story) {
        stories.removeAll { $0.id == story.id }
        if selectedStory?.id == story.id {
            selectedStory = nil
        }
        // In production, also delete from storage
    }

    func duplicateStory(_ story: Story) {
        let newStory = Story(
            id: UUID(),
            title: "\(story.title) (Copy)",
            subtitle: story.subtitle,
            author: story.author,
            createdDate: Date(),
            modifiedDate: Date(),
            slides: story.slides,
            template: story.template,
            thumbnailPath: story.thumbnailPath
        )
        stories.insert(newStory, at: 0)
        saveStory(newStory)
    }

    // MARK: - Slide Management

    func addSlide(to story: Story, at index: Int? = nil) {
        var updatedStory = story
        let newSlide = Slide()

        if let index = index {
            updatedStory.slides.insert(newSlide, at: index)
        } else {
            updatedStory.slides.append(newSlide)
        }

        updateStory(updatedStory)
    }

    func updateSlide(_ slide: Slide, in story: Story) {
        var updatedStory = story
        if let index = updatedStory.slides.firstIndex(where: { $0.id == slide.id }) {
            updatedStory.slides[index] = slide
            updateStory(updatedStory)
        }
    }

    func deleteSlide(_ slide: Slide, from story: Story) {
        var updatedStory = story
        updatedStory.slides.removeAll { $0.id == slide.id }
        updateStory(updatedStory)
    }

    func moveSlide(from source: IndexSet, to destination: Int, in story: Story) {
        var updatedStory = story
        updatedStory.slides.move(fromOffsets: source, toOffset: destination)
        updateStory(updatedStory)
    }

    // MARK: - Media Management

    func addMediaElement(_ element: MediaElement, to slide: Slide, in story: Story) {
        var updatedSlide = slide
        updatedSlide.mediaElements.append(element)
        updateSlide(updatedSlide, in: story)
    }

    func updateMediaElement(_ element: MediaElement, in slide: Slide, in story: Story) {
        var updatedSlide = slide
        if let index = updatedSlide.mediaElements.firstIndex(where: { $0.id == element.id }) {
            updatedSlide.mediaElements[index] = element
            updateSlide(updatedSlide, in: story)
        }
    }

    func deleteMediaElement(_ element: MediaElement, from slide: Slide, in story: Story) {
        var updatedSlide = slide
        updatedSlide.mediaElements.removeAll { $0.id == element.id }
        updateSlide(updatedSlide, in: story)
    }

    // MARK: - Persistence

    private func saveStory(_ story: Story) {
        // In production, save to UserDefaults, CoreData, or CloudKit
        // For now, just update the in-memory array
        print("💾 Saved story: \(story.title)")
    }

    // MARK: - Export

    func exportStory(_ story: Story) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(story)
    }

    func importStory(from data: Data) {
        let decoder = JSONDecoder()
        if let story = try? decoder.decode(Story.self, from: data) {
            stories.insert(story, at: 0)
            saveStory(story)
        } else {
            errorMessage = "Failed to import story"
        }
    }
}
