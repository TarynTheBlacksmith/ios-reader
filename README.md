# Resonate - iOS Multimedia Storytelling App

An iOS application that brings Nancy Duarte's "Resonate" principles to life through immersive multimedia storytelling.

## Concept

Resonate enables users to create compelling visual stories by combining multimedia elements with proven storytelling principles:

### Core Principles (from Nancy Duarte's Resonate)

1. **Story Structure** - Build narratives using the hero's journey and "what is" vs "what could be" contrast
2. **Audience Connection** - Create presentations that resonate emotionally with viewers
3. **Visual Storytelling** - Use rich media (images, video, audio) to enhance the narrative
4. **Contrast & Repetition** - Emphasize key points through visual and thematic patterns
5. **Call to Action** - Guide audiences from current state to desired future state

## Features

### Story Creation
- Create multi-slide stories with narrative flow
- Define "what is" and "what could be" sections
- Set emotional tone and pacing for each slide

### Multimedia Support
- Images and photo galleries
- Video clips with trimming
- Audio narration and background music
- Rich text with formatting

### Presentation Modes
- Full-screen immersive playback
- Smooth transitions between slides
- Auto-advance or manual control
- Portrait and landscape support

### Templates
- Pre-designed story structures based on Resonate principles
- Hero's journey template
- Problem-solution template
- Before-after transformation template

## Technical Stack

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive data flow
- **AVFoundation** - Video and audio playback
- **PhotosUI** - Media selection
- **Swift Data** - Local persistence

## Project Structure

```
ResonateApp/
├── App/
│   ├── ResonateApp.swift          # App entry point
│   └── ContentView.swift          # Root view
├── Models/
│   ├── Story.swift                # Story data model
│   ├── Slide.swift                # Slide model
│   ├── MediaElement.swift         # Media types
│   └── StoryTemplate.swift        # Template definitions
├── Views/
│   ├── StoryList/
│   │   ├── StoryListView.swift
│   │   └── StoryCard.swift
│   ├── Editor/
│   │   ├── StoryEditorView.swift
│   │   ├── SlideEditorView.swift
│   │   └── MediaPickerView.swift
│   └── Presentation/
│       ├── PresentationView.swift
│       └── SlideRenderer.swift
├── ViewModels/
│   ├── StoryViewModel.swift
│   └── PresentationViewModel.swift
└── Services/
    ├── MediaService.swift
    └── StorageService.swift
```

## Getting Started

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Build Instructions
1. Open `ResonateApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (Cmd+R)

## Design Philosophy

The app embodies Duarte's principle that "the most powerful person in the world is the storyteller." Every interaction is designed to help users craft narratives that move audiences from complacency to action.

## License

MIT
