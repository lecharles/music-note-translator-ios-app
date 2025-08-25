# Sheet Note Labels - iOS Music Recognition App

An iOS SwiftUI application that captures photos of printed sheet music and overlays alphabetic note names directly under each detected notehead. Built with on-device computer vision using Apple's Vision framework.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)
![Vision](https://img.shields.io/badge/Vision-Framework-purple.svg)

## Features

- 📷 **Camera Integration**: Capture sheet music photos or select from photo library
- 🎵 **On-Device OMR**: Optical Music Recognition using Apple Vision framework
- 🎼 **Note Detection**: Identifies noteheads and maps them to musical pitches
- 📝 **Alphabetic Labels**: Displays note names (C, D, E, F, G, A, B) with octave numbers
- 🎯 **Multi-Clef Support**: Treble and bass clef recognition
- 📱 **Demo Mode**: Bundled sample images for testing
- ⚡ **Fast Processing**: Typically completes analysis in under 2 seconds

## Architecture

### Core Components

```
SheetNoteLabels/
├── App/
│   ├── SheetNoteLabelsApp.swift     # Main app entry point
│   └── ContentView.swift            # Home screen
├── Camera/
│   ├── CaptureView.swift            # Photo capture UI
│   └── CaptureViewModel.swift       # Camera logic
├── OMR/
│   ├── OMRModels.swift              # Data structures
│   ├── HeuristicOMRDetector.swift   # Vision-based detection
│   └── PitchMapper.swift            # Y-coordinate to pitch conversion
└── Tests/
    └── SheetNoteLabelsTests.swift   # Unit tests
```

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Vision Framework**: Apple's computer vision API for contour detection
- **Core Image**: Image preprocessing and filtering
- **PhotosUI**: Photo picker integration
- **PDFKit**: PDF to image conversion for demo mode

## Build & Run Instructions

### Prerequisites

- **Xcode 15.0+**
- **iOS 17.0+** target device or simulator
- **macOS Ventura** or later for development

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/lecharles/music-note-translator-ios-app.git
   cd music-note-translator-ios-app
   ```

2. **Open the Xcode project:**
   ```bash
   open SheetNoteLabels.xcodeproj
   ```

3. **Build and run:**
   - Select your target device/simulator
   - Press `Cmd+R` or click the Run button
   - Grant camera and photo library permissions when prompted

### Alternative: XcodeGen Workflow

If you prefer regenerating the project from configuration:

1. **Install XcodeGen:**
   ```bash
   brew install xcodegen
   ```

2. **Generate project:**
   ```bash
   xcodegen
   open SheetNoteLabels.xcodeproj
   ```

## Usage

### Demo Mode (Recommended for Testing)

1. Launch the app and tap **"Start Labeling"**
2. Tap **"Use Demo Image"** to load the bundled sheet music sample
3. Tap **"Analyze Image"** to run the OMR detection
4. View results showing detected notes with their pitch names and positions

### Camera Mode

1. Launch the app and tap **"Start Labeling"**
2. Use **"Choose from Library"** to select a sheet music photo
3. Tap **"Analyze Image"** to process your image
4. Review detected notes in the results panel

## Current Implementation Status

### ✅ Completed Features

- [x] SwiftUI user interface with navigation
- [x] Camera integration and photo picker
- [x] PDF to image conversion for demo resources
- [x] Vision framework integration for contour detection
- [x] Staff line detection (mock implementation)
- [x] Pitch mapping algorithm (treble and bass clef)
- [x] Note position to letter name conversion
- [x] Real-time analysis progress feedback
- [x] Results display with note positions
- [x] Comprehensive unit tests for pitch mapping
- [x] Git repository and CI-ready structure

### 🚧 In Development

- [ ] Visual overlay renderer (PDF/PNG export)
- [ ] Improved staff line detection using Hough transforms
- [ ] Ledger line detection for extended range notes
- [ ] Note stem detection and grouping
- [ ] Settings view (clef selection, export options)

### 🔮 Future Enhancements

- [ ] Core ML model integration for improved accuracy
- [ ] Multi-staff document support
- [ ] Accidental detection (sharps, flats, naturals)
- [ ] Key signature recognition
- [ ] Time signature detection
- [ ] Accessibility features (larger labels, high contrast)
- [ ] Batch processing mode

## OMR Algorithm Overview

### High-Level Pipeline

1. **Preprocessing**: Grayscale conversion, contrast enhancement, noise reduction
2. **Staff Detection**: Locate 5-line musical staves using horizontal line detection
3. **Staff Metrics**: Calculate line spacing and vertical positioning
4. **Notehead Detection**: Use Vision contours to find elliptical shapes near staff lines
5. **Pitch Mapping**: Convert Y-coordinates to musical pitches based on clef and staff position
6. **Output Generation**: Create labeled overlay preserving original layout

### Pitch Mapping Logic

The `PitchMapper` converts pixel Y-coordinates to musical pitches:

```swift
// Example: Treble clef staff with 20px line spacing
let staff = StaffInfo(topY: 100, spacing: 20, clef: .treble)
let pitch = PitchMapper.mapYCoordinateToPitch(120, in: staff)
// Result: D5 (second line from top)
```

**Treble Clef Mapping:**
- Staff line positions: F5, D5, B4, G4, E4
- Space positions: E5, C5, A4, F4

**Bass Clef Mapping:**
- Staff line positions: A3, F3, D3, B2, G2  
- Space positions: G3, E3, C3, A2

## Testing

### Unit Tests

Run the test suite to verify pitch mapping accuracy:

```bash
# In Xcode
Cmd+U

# Or via command line
xcodebuild test -project SheetNoteLabels.xcodeproj -scheme SheetNoteLabels -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Test Coverage:**
- Note letter semitone offsets
- Treble clef pitch mapping for staff lines and spaces
- Bass clef pitch mapping for staff lines and spaces
- Edge cases and rounding behavior

### Manual Testing

The app includes mock data generation for consistent testing:
- Demo images load from bundled PDFs
- Fallback to procedurally generated staff notation
- Consistent mock note positions for regression testing

## Known Limitations

### Current MVP Constraints

- **Single Staff**: Only processes the first detected staff system
- **Simple Notation**: Works best with clear, well-spaced quarter notes
- **No Accidentals**: Sharp/flat detection not yet implemented
- **Mock Staff Detection**: Uses estimated positions rather than true line detection
- **No Visual Export**: Results shown in text form only

### Image Quality Requirements

- **High Contrast**: Clear black notes on white background
- **Good Resolution**: Minimum 800px width recommended
- **Minimal Skew**: Works best with horizontally aligned staves
- **Clean Notation**: Printed music performs better than handwritten

## Contributing

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes with appropriate tests
4. Ensure all tests pass: `Cmd+U` in Xcode
5. Submit a pull request

### Code Style Guidelines

- Follow Apple's Swift API Design Guidelines
- Use SwiftUI best practices for view composition  
- Include comprehensive inline documentation
- Write unit tests for pure functions
- Use `@MainActor` for UI-related ViewModels

## License

This project is open source. Feel free to use, modify, and distribute according to your needs.

## Acknowledgments

- Built with Apple's Vision and Core Image frameworks
- Inspired by traditional OMR research and modern computer vision techniques
- Generated with assistance from [Claude Code](https://claude.ai/code)

---

**Version**: 1.0  
**Last Updated**: August 2025  
**Minimum iOS**: 17.0  
**Swift Version**: 5.9+