//
//  MediaService.swift
//  ResonateApp
//
//  Service for handling media file operations
//

import Foundation
import SwiftUI
import AVFoundation
import Photos

@MainActor
class MediaService: ObservableObject {
    static let shared = MediaService()

    private let fileManager = FileManager.default
    private lazy var mediaDirectory: URL = {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mediaPath = documentsPath.appendingPathComponent("Media", isDirectory: true)

        if !fileManager.fileExists(atPath: mediaPath.path) {
            try? fileManager.createDirectory(at: mediaPath, withIntermediateDirectories: true)
        }

        return mediaPath
    }()

    private init() {}

    // MARK: - Image Handling

    func saveImage(_ image: UIImage) async throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let fileURL = mediaDirectory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw MediaError.compressionFailed
        }

        try data.write(to: fileURL)
        return filename
    }

    func loadImage(filename: String) -> UIImage? {
        let fileURL = mediaDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: data)
    }

    // MARK: - Video Handling

    func saveVideo(from sourceURL: URL) async throws -> String {
        let filename = UUID().uuidString + ".mp4"
        let destinationURL = mediaDirectory.appendingPathComponent(filename)

        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return filename
    }

    func getVideoURL(filename: String) -> URL {
        return mediaDirectory.appendingPathComponent(filename)
    }

    func getVideoDuration(filename: String) async -> TimeInterval? {
        let url = getVideoURL(filename: filename)
        let asset = AVAsset(url: url)

        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            return nil
        }
    }

    // MARK: - Audio Handling

    func saveAudio(from sourceURL: URL) async throws -> String {
        let filename = UUID().uuidString + ".m4a"
        let destinationURL = mediaDirectory.appendingPathComponent(filename)

        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return filename
    }

    func getAudioURL(filename: String) -> URL {
        return mediaDirectory.appendingPathComponent(filename)
    }

    func getAudioDuration(filename: String) async -> TimeInterval? {
        let url = getAudioURL(filename: filename)
        let asset = AVAsset(url: url)

        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            return nil
        }
    }

    // MARK: - File Management

    func deleteMedia(filename: String) throws {
        let fileURL = mediaDirectory.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    func getTotalMediaSize() throws -> Int64 {
        let contents = try fileManager.contentsOfDirectory(
            at: mediaDirectory,
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

    func cleanupUnusedMedia(usedFilenames: Set<String>) throws {
        let contents = try fileManager.contentsOfDirectory(
            at: mediaDirectory,
            includingPropertiesForKeys: nil
        )

        for url in contents {
            let filename = url.lastPathComponent
            if !usedFilenames.contains(filename) {
                try fileManager.removeItem(at: url)
            }
        }
    }

    // MARK: - Permissions

    func requestPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            return await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func requestMicrophonePermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
}

// MARK: - Errors

enum MediaError: LocalizedError {
    case compressionFailed
    case fileNotFound
    case invalidFormat
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress media file"
        case .fileNotFound:
            return "Media file not found"
        case .invalidFormat:
            return "Invalid media format"
        case .permissionDenied:
            return "Permission denied to access media"
        }
    }
}
