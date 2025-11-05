//
//  StoryEditorView.swift
//  ResonateApp
//
//  Main story editing interface
//

import SwiftUI

struct StoryEditorView: View {
    @EnvironmentObject var viewModel: StoryViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var isPresenting: Bool

    @State private var story: Story
    @State private var selectedSlideIndex: Int = 0
    @State private var showingSlideEditor = false
    @State private var showingPresentation = false

    init(story: Story, isPresenting: Binding<Bool>) {
        _story = State(initialValue: story)
        _isPresenting = isPresenting
    }

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                // Slide list sidebar
                slideListSidebar
                    .frame(minWidth: Layout.sidebarMinWidth, idealWidth: Layout.sidebarWidth, maxWidth: Layout.sidebarMaxWidth)
                    .background(AppColors.groupedBackground)

                Divider()

                // Main editing area
                slidePreviewArea
            }
            .navigationTitle(story.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        saveAndClose()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingPresentation = true
                    } label: {
                        Label("Present", systemImage: "play.fill")
                    }
                    .primaryButtonStyle()
                }
            }
            .sheet(isPresented: $showingSlideEditor) {
                if selectedSlideIndex < story.slides.count {
                    SlideEditorView(
                        slide: $story.slides[selectedSlideIndex],
                        story: story
                    )
                }
            }
            .fullScreenCover(isPresented: $showingPresentation) {
                PresentationView(story: story, isPresenting: $showingPresentation)
            }
        }
    }

    // MARK: - Slide List Sidebar

    private var slideListSidebar: some View {
        VStack(spacing: 0) {
            // Story info
            VStack(alignment: .leading, spacing: Spacing.small) {
                TextField("Story Title", text: $story.title)
                    .font(AppFonts.headline)
                    .textFieldStyle(.roundedBorder)

                TextField("Subtitle", text: $story.subtitle)
                    .font(AppFonts.subheadline)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: Spacing.medium) {
                    Label("\(story.slideCount)", systemImage: "square.stack.3d.up")
                    Spacer()
                    Label(story.formattedDuration, systemImage: "clock")
                }
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
            }
            .padding(Spacing.medium)
            .background(AppColors.background)

            Divider()

            // Slide thumbnails
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(story.slides.enumerated()), id: \.element.id) { index, slide in
                        slideListRow(slide: slide, index: index)
                            .id(index)
                            .listRowInsets(EdgeInsets(top: Spacing.xxSmall, leading: Spacing.small, bottom: Spacing.xxSmall, trailing: Spacing.small))
                            .listRowBackground(
                                selectedSlideIndex == index ?
                                    RoundedRectangle(cornerRadius: CornerRadius.small)
                                        .fill(AppColors.primary.opacity(0.15))
                                        .padding(.horizontal, Spacing.xxSmall)
                                    : nil
                            )
                            .onTapGesture {
                                withAnimation(AppAnimations.quick) {
                                    selectedSlideIndex = index
                                }
                            }
                    }
                    .onMove { from, to in
                        story.slides.move(fromOffsets: from, toOffset: to)
                        if let first = from.first {
                            selectedSlideIndex = to > first ? to - 1 : to
                        }
                    }
                    .onDelete { indexSet in
                        story.slides.remove(atOffsets: indexSet)
                        if selectedSlideIndex >= story.slides.count {
                            selectedSlideIndex = max(0, story.slides.count - 1)
                        }
                    }
                }
                .listStyle(.plain)
            }

            Divider()

            // Add slide button
            Button {
                addSlide()
            } label: {
                Label("Add Slide", systemImage: "plus.square")
                    .font(AppFonts.bodyEmphasis)
                    .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
            .padding(Spacing.medium)
        }
    }

    private func slideListRow(slide: Slide, index: Int) -> some View {
        HStack(spacing: Spacing.small) {
            // Slide number
            Text("\(index + 1)")
                .font(AppFonts.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 28)

            // Thumbnail - larger and more visible
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .fill(slide.role.color.opacity(0.3))
                    .frame(width: 80, height: 60)

                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .strokeBorder(slide.role.color, lineWidth: 2)
                    .frame(width: 80, height: 60)

                Text(slide.role.description)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(Spacing.xxSmall)
            }

            // Info
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(slide.title)
                    .font(AppFonts.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: Spacing.xxSmall) {
                    if slide.hasAutoAdvance {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Text("\(slide.mediaElements.count) elements")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.xxSmall)
    }

    // MARK: - Slide Preview Area

    private var slidePreviewArea: some View {
        VStack {
            if selectedSlideIndex < story.slides.count {
                let slide = story.slides[selectedSlideIndex]

                ScrollView {
                    VStack(spacing: 20) {
                        // Slide preview
                        SlidePreview(slide: slide)
                            .frame(maxWidth: 800)
                            .aspectRatio(16/9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 10)

                        // Edit button
                        Button {
                            showingSlideEditor = true
                        } label: {
                            Label("Edit Slide", systemImage: "pencil")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        // Slide info
                        slideInfoCard(slide)
                            .frame(maxWidth: 600)
                    }
                    .padding()
                }
            } else {
                emptySlideState
            }
        }
    }

    private func slideInfoCard(_ slide: Slide) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Slide Details", systemImage: "info.circle")
                    .font(.headline)
                Spacer()
            }

            Divider()

            infoRow(label: "Role", value: slide.role.description)
            infoRow(label: "Transition", value: slide.transition.displayName)
            infoRow(label: "Media Elements", value: "\(slide.mediaElements.count)")

            if slide.hasAutoAdvance {
                infoRow(label: "Duration", value: String(format: "%.1fs", slide.duration))
            } else {
                infoRow(label: "Advance", value: "Manual")
            }

            if !slide.notes.isEmpty {
                Divider()
                Text("Notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(slide.notes)
                    .font(.body)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }

    private var emptySlideState: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No slides yet")
                .font(.title2)

            Button {
                addSlide()
            } label: {
                Label("Add First Slide", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Actions

    private func addSlide() {
        let newSlide = Slide()
        story.slides.append(newSlide)
        selectedSlideIndex = story.slides.count - 1
        showingSlideEditor = true
    }

    private func saveAndClose() {
        viewModel.updateStory(story)
        dismiss()
    }
}

// MARK: - Slide Preview

struct SlidePreview: View {
    let slide: Slide

    var body: some View {
        ZStack {
            // Background
            hexToColor(slide.backgroundColor)

            // Media elements (simplified preview)
            ForEach(slide.mediaElements) { element in
                MediaElementPreview(element: element)
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

struct MediaElementPreview: View {
    let element: MediaElement

    var body: some View {
        GeometryReader { geometry in
            let xPos = element.position.x * geometry.size.width
            let yPos = element.position.y * geometry.size.height
            let width = element.size.width * geometry.size.width
            let height = element.size.height * geometry.size.height

            Group {
                switch element.type {
                case .text:
                    if let text = element.textContent {
                        Text(text)
                            .font(.system(size: element.fontSize ?? 24))
                            .multilineTextAlignment(.center)
                            .frame(width: width, height: height)
                    }

                case .image:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                        .foregroundStyle(.secondary)

                case .video:
                    Image(systemName: "video.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                        .foregroundStyle(.secondary)

                case .audio:
                    Image(systemName: "waveform")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                        .foregroundStyle(.secondary)
                }
            }
            .position(x: xPos, y: yPos)
        }
    }
}

#Preview {
    StoryEditorView(story: .sample, isPresenting: .constant(false))
        .environmentObject(StoryViewModel())
}
