# Resonate App - Xcode Project Setup

## Overview
This document provides instructions for setting up the Resonate iOS app in Xcode.

## File Structure

The project is organized as follows:

```
ResonateApp/
├── App/
│   ├── ResonateApp.swift          # Main app entry point (@main)
│   └── ContentView.swift          # Root navigation view
├── Models/
│   ├── MediaElement.swift         # Media element data model
│   ├── Slide.swift                # Slide model with narrative roles
│   └── Story.swift                # Story container and templates
├── Views/
│   ├── StoryList/
│   │   ├── StoryListView.swift    # Story library grid
│   │   ├── StoryCard.swift        # Story preview card
│   │   └── CreateStoryView.swift  # New story creation sheet
│   ├── Editor/
│   │   ├── StoryEditorView.swift  # Main story editor
│   │   ├── SlideEditorView.swift  # Slide property editor
│   │   └── MediaPickerView.swift  # Media selection interface
│   └── Presentation/
│       ├── PresentationView.swift # Full-screen presentation
│       └── SlideRenderer.swift    # Slide rendering engine
├── ViewModels/
│   ├── StoryViewModel.swift       # Story management logic
│   └── PresentationViewModel.swift # Presentation playback
└── Resources/
    └── Info.plist                 # App configuration
```

## Creating the Xcode Project

### Option 1: Manual Setup in Xcode

1. **Open Xcode** (15.0 or later)

2. **Create New Project**
   - File → New → Project
   - Choose "iOS" → "App"
   - Product Name: `ResonateApp`
   - Team: Select your team
   - Organization Identifier: Your identifier (e.g., `com.yourname`)
   - Interface: SwiftUI
   - Language: Swift
   - Minimum iOS Version: iOS 17.0

3. **Replace Default Files**
   - Delete the default `ContentView.swift` and `ResonateAppApp.swift`
   - Drag all files from this repository into Xcode
   - Ensure "Copy items if needed" is checked
   - Select "Create groups" for folder structure

4. **Configure Build Settings**
   - Select project in navigator
   - General tab:
     - Deployment Target: iOS 17.0
     - Supported Destinations: iPhone, iPad
     - Display Name: Resonate
   - Info tab:
     - Custom iOS Target Properties: Import from Info.plist

5. **Add Frameworks** (if needed)
   - General → Frameworks, Libraries, and Embedded Content
   - Add: AVFoundation, PhotosUI, Combine (should be auto-linked)

### Option 2: Using Package.swift (Swift Package)

If you prefer to work with Swift Package Manager:

```swift
// Package.swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ResonateApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ResonateApp",
            targets: ["ResonateApp"]
        )
    ],
    targets: [
        .target(
            name: "ResonateApp",
            path: "ResonateApp"
        )
    ]
)
```

## Build Configuration

### Required Capabilities
- Camera usage (for capturing media)
- Photo Library access (for selecting images)
- Microphone access (for audio recording)

### Privacy Descriptions (in Info.plist)
- `NSPhotoLibraryUsageDescription`: "Resonate needs access to your photo library to add images to your stories."
- `NSCameraUsageDescription`: "Resonate needs access to your camera to capture photos for your stories."
- `NSMicrophoneUsageDescription`: "Resonate needs access to your microphone to record audio narration."

### Supported Orientations
- Portrait
- Landscape Left
- Landscape Right
- Portrait Upside Down (iPad only)

## Running the App

1. **Select Target Device**
   - Choose iPhone or iPad simulator (iOS 17.0+)
   - Or connect physical device with iOS 17.0+

2. **Build and Run**
   - Press Cmd+R or click the Play button
   - Wait for build to complete

3. **First Launch**
   - App will load with sample stories
   - Tap "+" to create a new story
   - Choose a template based on Resonate principles

## Key Features to Test

### Story Creation
- Create new story from templates
- Edit story title and subtitle
- View story analytics (slide count, duration)

### Slide Editor
- Add/remove/reorder slides
- Set narrative role (What Is, What Could Be, etc.)
- Configure transitions and timing
- Add media elements (text, images, video, audio)

### Presentation Mode
- Full-screen slideshow
- Auto-advance or manual control
- Smooth transitions
- Progress indicators
- Navigation controls

## Development Notes

### State Management
- Uses `@StateObject` and `@ObservableObject` for reactive updates
- `StoryViewModel` manages all stories globally
- `PresentationViewModel` handles playback state per presentation

### Data Persistence
- Currently uses in-memory storage
- Sample data provided for demonstration
- TODO: Implement CoreData or SwiftData for persistence
- TODO: Add iCloud sync support

### Media Handling
- Placeholders provided for image/video/audio
- TODO: Implement actual media loading with AVFoundation
- TODO: Add media compression and optimization
- TODO: Implement media library management

### Future Enhancements
- Export to video format
- Share stories via link
- Collaborative editing
- Analytics dashboard
- Custom themes and templates
- Background music library
- Voice-over recording

## Troubleshooting

### Build Errors
- Ensure deployment target is set to iOS 17.0+
- Check that all files are included in target membership
- Verify team signing is configured

### Runtime Issues
- Check console for SwiftUI view errors
- Verify StateObject initialization
- Ensure all bindings are properly connected

### Performance
- Test on physical device for accurate performance
- Monitor memory usage with large media files
- Optimize image rendering for large slideshows

## Design Principles

This app embodies Nancy Duarte's Resonate principles:

1. **Story Structure** - Templates guide users through hero's journey and contrast patterns
2. **Audience Connection** - Focus on "what is" vs "what could be" narrative arcs
3. **Visual Storytelling** - Rich multimedia support for emotional impact
4. **Contrast & Repetition** - Slide roles create natural rhythm and emphasis
5. **Call to Action** - Dedicated slide types for inspiring transformation

## Resources

- [Nancy Duarte's Resonate](https://www.duarte.com/books/resonate/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [AVFoundation](https://developer.apple.com/av-foundation/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)

## License
MIT
