//
//  PresentationViewModel.swift
//  ResonateApp
//
//  Manages presentation playback and slide transitions
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PresentationViewModel: ObservableObject {
    @Published var story: Story
    @Published var currentSlideIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0.0
    @Published var showControls: Bool = true

    private var timer: Timer?
    private var slideStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    var currentSlide: Slide? {
        guard currentSlideIndex < story.slides.count else { return nil }
        return story.slides[currentSlideIndex]
    }

    var isFirstSlide: Bool {
        currentSlideIndex == 0
    }

    var isLastSlide: Bool {
        currentSlideIndex == story.slides.count - 1
    }

    var canAdvance: Bool {
        !isLastSlide
    }

    var canGoBack: Bool {
        !isFirstSlide
    }

    init(story: Story) {
        self.story = story
    }

    // MARK: - Playback Control

    func play() {
        isPlaying = true
        startSlideTimer()
    }

    func pause() {
        isPlaying = false
        stopSlideTimer()
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func nextSlide() {
        guard canAdvance else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            currentSlideIndex += 1
            progress = 0.0
        }

        if isPlaying {
            startSlideTimer()
        }
    }

    func previousSlide() {
        guard canGoBack else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            currentSlideIndex -= 1
            progress = 0.0
        }

        if isPlaying {
            startSlideTimer()
        }
    }

    func goToSlide(_ index: Int) {
        guard index >= 0 && index < story.slides.count else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            currentSlideIndex = index
            progress = 0.0
        }

        if isPlaying {
            startSlideTimer()
        }
    }

    func restart() {
        currentSlideIndex = 0
        progress = 0.0
        pause()
    }

    // MARK: - Timer Management

    private func startSlideTimer() {
        stopSlideTimer()

        guard let slide = currentSlide, slide.hasAutoAdvance else {
            return
        }

        slideStartTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateProgress()
            }
        }
    }

    private func stopSlideTimer() {
        timer?.invalidate()
        timer = nil
        slideStartTime = nil
    }

    private func updateProgress() {
        guard let slide = currentSlide,
              let startTime = slideStartTime,
              slide.hasAutoAdvance else {
            return
        }

        let elapsed = Date().timeIntervalSince(startTime)
        progress = min(elapsed / slide.duration, 1.0)

        // Auto-advance when complete
        if progress >= 1.0 {
            if canAdvance {
                nextSlide()
            } else {
                pause()
            }
        }
    }

    // MARK: - Control Visibility

    func toggleControls() {
        withAnimation {
            showControls.toggle()
        }
    }

    func hideControls() {
        withAnimation {
            showControls = false
        }
    }

    func showControlsBriefly() {
        showControls = true

        // Hide after 3 seconds if playing
        if isPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                if self?.isPlaying == true {
                    self?.hideControls()
                }
            }
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        stopSlideTimer()
        cancellables.removeAll()
    }

    deinit {
        // Timer cleanup happens automatically when the object is deallocated
        // Cannot call main actor isolated methods from deinit
        timer?.invalidate()
    }
}
