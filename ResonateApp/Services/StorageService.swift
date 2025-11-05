//
//  StorageService.swift
//  ResonateApp
//
//  Service for persisting stories to disk
//

import Foundation

@MainActor
class StorageService: ObservableObject {
    static let shared = StorageService()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private lazy var storiesDirectory: URL = {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storiesPath = documentsPath.appendingPathComponent("Stories", isDirectory: true)

        if !fileManager.fileExists(atPath: storiesPath.path) {
            try? fileManager.createDirectory(at: storiesPath, withIntermediateDirectories: true)
        }

        return storiesPath
    }()

    private init() {
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Story Persistence

    func saveStory(_ story: Story) async throws {
        let filename = story.id.uuidString + ".json"
        let fileURL = storiesDirectory.appendingPathComponent(filename)

        let data = try encoder.encode(story)
        try data.write(to: fileURL)

        print("✅ Saved story: \(story.title) to \(filename)")
    }

    func loadStory(id: UUID) async throws -> Story {
        let filename = id.uuidString + ".json"
        let fileURL = storiesDirectory.appendingPathComponent(filename)

        let data = try Data(contentsOf: fileURL)
        let story = try decoder.decode(Story.self, from: data)

        return story
    }

    func loadAllStories() async throws -> [Story] {
        let contents = try fileManager.contentsOfDirectory(
            at: storiesDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )

        var stories: [Story] = []

        for url in contents where url.pathExtension == "json" {
            do {
                let data = try Data(contentsOf: url)
                let story = try decoder.decode(Story.self, from: data)
                stories.append(story)
            } catch {
                print("⚠️ Failed to load story from \(url.lastPathComponent): \(error)")
            }
        }

        // Sort by modification date, newest first
        return stories.sorted { $0.modifiedDate > $1.modifiedDate }
    }

    func deleteStory(_ story: Story) async throws {
        let filename = story.id.uuidString + ".json"
        let fileURL = storiesDirectory.appendingPathComponent(filename)

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("🗑 Deleted story: \(story.title)")
        }
    }

    func storyExists(id: UUID) -> Bool {
        let filename = id.uuidString + ".json"
        let fileURL = storiesDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: fileURL.path)
    }

    // MARK: - Export/Import

    func exportStory(_ story: Story) throws -> Data {
        return try encoder.encode(story)
    }

    func importStory(from data: Data) throws -> Story {
        let decodedStory = try decoder.decode(Story.self, from: data)

        // Generate new ID to avoid conflicts by creating a new instance
        let story = Story(
            id: UUID(),
            title: decodedStory.title,
            subtitle: decodedStory.subtitle,
            author: decodedStory.author,
            createdDate: Date(),
            modifiedDate: Date(),
            slides: decodedStory.slides,
            template: decodedStory.template,
            thumbnailPath: decodedStory.thumbnailPath
        )

        return story
    }

    func exportStoryToFile(_ story: Story) throws -> URL {
        let data = try encoder.encode(story)
        let tempURL = fileManager.temporaryDirectory
            .appendingPathComponent("\(story.title).resonate")

        try data.write(to: tempURL)
        return tempURL
    }

    func importStoryFromFile(_ url: URL) async throws -> Story {
        let data = try Data(contentsOf: url)
        return try importStory(from: data)
    }

    // MARK: - Backup

    func backupAllStories() async throws -> URL {
        let stories = try await loadAllStories()
        let data = try encoder.encode(stories)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let dateString = dateFormatter.string(from: Date())

        let backupURL = fileManager.temporaryDirectory
            .appendingPathComponent("resonate-backup-\(dateString).json")

        try data.write(to: backupURL)
        return backupURL
    }

    func restoreFromBackup(_ url: URL) async throws -> [Story] {
        let data = try Data(contentsOf: url)
        let stories = try decoder.decode([Story].self, from: data)

        // Save all imported stories
        for story in stories {
            try await saveStory(story)
        }

        return stories
    }

    // MARK: - Storage Info

    func getTotalStorageSize() throws -> Int64 {
        let contents = try fileManager.contentsOfDirectory(
            at: storiesDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        )

        var totalSize: Int64 = 0
        for url in contents {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? Int64 {
                totalSize += size
            }
        }

        return totalSize
    }

    func getStoryCount() throws -> Int {
        let contents = try fileManager.contentsOfDirectory(
            at: storiesDirectory,
            includingPropertiesForKeys: nil
        )

        return contents.filter { $0.pathExtension == "json" }.count
    }

    // MARK: - Cleanup

    func deleteAllStories() async throws {
        let contents = try fileManager.contentsOfDirectory(
            at: storiesDirectory,
            includingPropertiesForKeys: nil
        )

        for url in contents {
            try fileManager.removeItem(at: url)
        }

        print("🗑 Deleted all stories")
    }
}

// MARK: - Errors

enum StorageError: LocalizedError {
    case fileNotFound
    case encodingFailed
    case decodingFailed
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Story file not found"
        case .encodingFailed:
            return "Failed to encode story data"
        case .decodingFailed:
            return "Failed to decode story data"
        case .invalidFormat:
            return "Invalid story file format"
        }
    }
}
