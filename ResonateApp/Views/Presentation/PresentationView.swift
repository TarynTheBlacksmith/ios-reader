//
//  PresentationView.swift
//  ResonateApp
//
//  Full-screen presentation mode with transitions
//

import SwiftUI

struct PresentationView: View {
    @StateObject private var viewModel: PresentationViewModel
    @Binding var isPresenting: Bool
    @State private var showingControls = true
    @State private var autoHideTask: Task<Void, Never>?

    init(story: Story, isPresenting: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: PresentationViewModel(story: story))
        _isPresenting = isPresenting
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Current slide
            if let slide = viewModel.currentSlide {
                SlideRenderer(
                    slide: slide,
                    isVisible: true
                )
                .transition(transitionForSlide(slide))
                .id(slide.id)
            }

            // Controls overlay
            if showingControls {
                controlsOverlay
                    .transition(.opacity)
            }

            // Progress indicator
            if viewModel.isPlaying, let slide = viewModel.currentSlide, slide.hasAutoAdvance {
                progressBar
            }
        }
        .statusBar(hidden: !showingControls)
        .persistentSystemOverlays(showingControls ? .automatic : .hidden)
        .onTapGesture {
            withAnimation {
                showingControls.toggle()
            }
            scheduleAutoHide()
        }
        .onAppear {
            scheduleAutoHide()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    // MARK: - Controls Overlay

    private var controlsOverlay: some View {
        VStack {
            // Top bar
            HStack {
                Button {
                    isPresenting = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }

                Spacer()

                Text("\(viewModel.currentSlideIndex + 1) / \(viewModel.story.slideCount)")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                Spacer()

                Menu {
                    Button {
                        viewModel.restart()
                    } label: {
                        Label("Restart", systemImage: "backward.end")
                    }

                    ForEach(Array(viewModel.story.slides.enumerated()), id: \.element.id) { index, slide in
                        Button {
                            viewModel.goToSlide(index)
                        } label: {
                            Text("\(index + 1). \(slide.title)")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }
            }
            .padding()

            Spacer()

            // Bottom controls
            HStack(spacing: 40) {
                Button {
                    viewModel.previousSlide()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(viewModel.canGoBack ? .white : .gray)
                }
                .disabled(!viewModel.canGoBack)

                Button {
                    viewModel.togglePlayPause()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(.white)
                }

                Button {
                    viewModel.nextSlide()
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(viewModel.canAdvance ? .white : .gray)
                }
                .disabled(!viewModel.canAdvance)
            }
            .shadow(radius: 4)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.white.opacity(0.3))
                        .frame(height: 4)

                    Rectangle()
                        .fill(.white)
                        .frame(width: geometry.size.width * viewModel.progress, height: 4)
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Transitions

    private func transitionForSlide(_ slide: Slide) -> AnyTransition {
        switch slide.transition {
        case .fade:
            return .opacity

        case .slide:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )

        case .zoom:
            return .scale(scale: 0.8).combined(with: .opacity)

        case .dissolve:
            return .opacity.combined(with: .scale(scale: 1.1))
        }
    }

    // MARK: - Auto-hide Controls

    private func scheduleAutoHide() {
        autoHideTask?.cancel()

        guard viewModel.isPlaying else { return }

        autoHideTask = Task {
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                withAnimation {
                    showingControls = false
                }
            }
        }
    }
}

#Preview {
    PresentationView(story: .sample, isPresenting: .constant(true))
}
