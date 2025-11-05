//
//  SlideEditorView.swift
//  ResonateApp
//
//  Editor for individual slide properties and media
//

import SwiftUI

struct SlideEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var slide: Slide
    let story: Story

    @State private var showingMediaPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Slide Title", text: $slide.title)

                    Picker("Narrative Role", selection: $slide.role) {
                        ForEach(SlideRole.allCases, id: \.self) { role in
                            HStack {
                                Circle()
                                    .fill(role.color)
                                    .frame(width: 12, height: 12)
                                Text(role.description)
                            }
                            .tag(role)
                        }
                    }
                }

                Section("Appearance") {
                    ColorPicker("Background Color", selection: Binding(
                        get: { hexToColor(slide.backgroundColor) },
                        set: { slide.backgroundColor = colorToHex($0) }
                    ))

                    Picker("Transition", selection: $slide.transition) {
                        ForEach(TransitionStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                }

                Section("Timing") {
                    Toggle("Auto-advance", isOn: Binding(
                        get: { slide.hasAutoAdvance },
                        set: { if $0 { slide.duration = 3.0 } else { slide.duration = 0 } }
                    ))

                    if slide.hasAutoAdvance {
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text(String(format: "%.1fs", slide.duration))
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $slide.duration, in: 1...30, step: 0.5)
                    }
                }

                Section("Media Elements") {
                    if slide.mediaElements.isEmpty {
                        Text("No media elements yet")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(slide.mediaElements) { element in
                            mediaElementRow(element)
                        }
                        .onDelete { indexSet in
                            slide.mediaElements.remove(atOffsets: indexSet)
                        }
                        .onMove { from, to in
                            slide.mediaElements.move(fromOffsets: from, toOffset: to)
                        }
                    }

                    Button {
                        showingMediaPicker = true
                    } label: {
                        Label("Add Media", systemImage: "plus.circle")
                    }
                }

                Section("Speaker Notes") {
                    TextEditor(text: $slide.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Slide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMediaPicker) {
                MediaPickerView(slide: $slide)
            }
        }
    }

    private func mediaElementRow(_ element: MediaElement) -> some View {
        HStack {
            Image(systemName: element.type.icon)
                .foregroundStyle(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                if let text = element.textContent {
                    Text(text)
                        .lineLimit(1)
                } else {
                    Text(element.type.rawValue.capitalized)
                }

                Text("Position: (\(Int(element.position.x * 100))%, \(Int(element.position.y * 100))%)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if element.fadeIn || element.fadeOut {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    // MARK: - Color Helpers

    private func hexToColor(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }
        return Color(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }

    private func colorToHex(_ color: Color) -> String {
        let components = UIColor(color).cgColor.components ?? [1, 1, 1]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    SlideEditorView(slide: .constant(.sample), story: .sample)
}
