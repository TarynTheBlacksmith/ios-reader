//
//  MediaPickerView.swift
//  ResonateApp
//
//  Interface for adding media elements to slides
//

import SwiftUI
import PhotosUI

struct MediaPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var slide: Slide

    @State private var selectedMediaType: MediaType = .text
    @State private var textContent = ""
    @State private var fontSize: CGFloat = 24
    @State private var textAlignment: TextAlignment = .center
    @State private var positionX: Double = 0.5
    @State private var positionY: Double = 0.5
    @State private var sizeWidth: Double = 0.8
    @State private var sizeHeight: Double = 0.2
    @State private var fadeIn = false
    @State private var fadeOut = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Media Type") {
                    Picker("Type", selection: $selectedMediaType) {
                        ForEach(MediaType.allCases, id: \.self) { type in
                            Label(type.rawValue.capitalized, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Content") {
                    switch selectedMediaType {
                    case .text:
                        textContentSection

                    case .image:
                        imageContentSection

                    case .video:
                        videoContentSection

                    case .audio:
                        audioContentSection
                    }
                }

                Section("Position & Size") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Position")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Text("X:")
                            Slider(value: $positionX, in: 0...1)
                            Text("\(Int(positionX * 100))%")
                                .frame(width: 50)
                        }

                        HStack {
                            Text("Y:")
                            Slider(value: $positionY, in: 0...1)
                            Text("\(Int(positionY * 100))%")
                                .frame(width: 50)
                        }

                        Divider()

                        Text("Size")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Text("W:")
                            Slider(value: $sizeWidth, in: 0.1...1)
                            Text("\(Int(sizeWidth * 100))%")
                                .frame(width: 50)
                        }

                        HStack {
                            Text("H:")
                            Slider(value: $sizeHeight, in: 0.1...1)
                            Text("\(Int(sizeHeight * 100))%")
                                .frame(width: 50)
                        }
                    }
                }

                Section("Animation") {
                    Toggle("Fade In", isOn: $fadeIn)
                    Toggle("Fade Out", isOn: $fadeOut)
                }

                Section {
                    previewSection
                }
            }
            .navigationTitle("Add Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMediaElement()
                    }
                    .disabled(!canAddMedia)
                }
            }
        }
    }

    // MARK: - Content Sections

    private var textContentSection: some View {
        Group {
            TextEditor(text: $textContent)
                .frame(minHeight: 100)
                .overlay(alignment: .topLeading) {
                    if textContent.isEmpty {
                        Text("Enter text...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }

            HStack {
                Text("Font Size")
                Spacer()
                Text("\(Int(fontSize))pt")
                    .foregroundStyle(.secondary)
            }

            Slider(value: $fontSize, in: 12...72, step: 1)

            Picker("Alignment", selection: $textAlignment) {
                Label("Left", systemImage: "text.alignleft").tag(TextAlignment.leading)
                Label("Center", systemImage: "text.aligncenter").tag(TextAlignment.center)
                Label("Right", systemImage: "text.alignright").tag(TextAlignment.trailing)
            }
            .pickerStyle(.segmented)
        }
    }

    private var imageContentSection: some View {
        VStack {
            Button {
                // In production, open photo picker
            } label: {
                Label("Choose Image", systemImage: "photo.on.rectangle")
            }

            Text("Photo picker integration")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var videoContentSection: some View {
        VStack {
            Button {
                // In production, open video picker
            } label: {
                Label("Choose Video", systemImage: "video")
            }

            Text("Video picker integration")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var audioContentSection: some View {
        VStack {
            Button {
                // In production, open audio picker or recorder
            } label: {
                Label("Choose Audio", systemImage: "waveform")
            }

            Text("Audio picker/recorder integration")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack {
                Color.gray.opacity(0.1)

                if selectedMediaType == .text && !textContent.isEmpty {
                    Text(textContent)
                        .font(.system(size: fontSize))
                        .multilineTextAlignment(
                            textAlignment == .leading ? .leading :
                            textAlignment == .center ? .center : .trailing
                        )
                        .padding()
                } else {
                    Image(systemName: selectedMediaType.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Actions

    private var canAddMedia: Bool {
        switch selectedMediaType {
        case .text:
            return !textContent.isEmpty
        case .image, .video, .audio:
            return true // In production, check if media is selected
        }
    }

    private func addMediaElement() {
        let newElement = MediaElement(
            type: selectedMediaType,
            resourcePath: nil,
            textContent: selectedMediaType == .text ? textContent : nil,
            position: CGPoint(x: positionX, y: positionY),
            size: CGSize(width: sizeWidth, height: sizeHeight),
            fadeIn: fadeIn,
            fadeOut: fadeOut,
            fontSize: selectedMediaType == .text ? fontSize : nil,
            alignment: textAlignment
        )

        slide.mediaElements.append(newElement)
        dismiss()
    }
}

#Preview {
    MediaPickerView(slide: .constant(.sample))
}
