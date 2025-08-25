# Development Guide

This guide covers the development workflow, debugging procedures, and contribution guidelines for the Sheet Note Labels iOS app.

## 🏗️ **Project Architecture**

### **Directory Structure**
```
SheetNoteLabels/
├── App/
│   ├── SheetNoteLabelsApp.swift         # Main app entry point
│   ├── ContentView.swift                # Home screen
│   └── CaptureView.swift               # Photo capture interface
├── Camera/
│   └── CaptureViewModel.swift          # Photo logic and state
├── OMR/ (Optical Music Recognition)
│   ├── OMRModels.swift                 # Data structures and protocols
│   ├── HeuristicOMRDetector.swift      # Vision-based detection
│   └── PitchMapper.swift               # Y-coordinate to pitch conversion
├── Rendering/
│   ├── OverlayRenderer.swift           # Visual label overlay system
│   └── PreviewView.swift               # Results display and export
└── Resources/
    ├── sheet-music-example-with-notes.pdf
    └── sheet-music-example-with-notes-unlabelled.pdf
```

### **Key Components**

#### **OMR Pipeline**
1. **Image Input** → Camera or PhotosPicker
2. **Preprocessing** → Grayscale, contrast, noise reduction  
3. **Staff Detection** → Find 5-line musical staves
4. **Note Detection** → Identify noteheads using Vision contours
5. **Pitch Mapping** → Convert Y-coordinates to musical pitches
6. **Visual Overlay** → Draw labels below noteheads
7. **Export** → PDF/PNG with embedded labels

#### **Data Flow**
```
UIImage → HeuristicOMRDetector → OMRResult → OverlayRenderer → Labeled UIImage
```

## 🛠️ **Development Setup**

### **Prerequisites**
- **Xcode 15.0+** with iOS 17.0+ SDK
- **macOS Ventura** or later
- **Physical iOS device** (recommended for camera testing)
- **XcodeGen** (optional, for project regeneration)

### **Building the Project**

#### **Standard Workflow**
```bash
# Clone repository
git clone https://github.com/lecharles/music-note-translator-ios-app.git
cd music-note-translator-ios-app

# Open Xcode project
open SheetNoteLabels.xcodeproj

# Build and run (Cmd+R)
```

#### **XcodeGen Workflow** (Alternative)
```bash
# Install XcodeGen
brew install xcodegen

# Generate project from YAML config
xcodegen

# Open generated project
open SheetNoteLabels.xcodeproj
```

### **Testing Setup**

#### **Unit Tests**
```bash
# Run via Xcode: Cmd+U
# Or via command line:
xcodebuild test -project SheetNoteLabels.xcodeproj \
                -scheme SheetNoteLabels \
                -destination 'platform=iOS Simulator,name=iPhone 15'
```

#### **Manual Testing**
1. **Demo Mode**: Use "Use Demo Image" → "Analyze Image" → "View Labeled Image"  
2. **Camera Mode**: Capture real sheet music photos
3. **Export Testing**: Test PDF export and sharing functionality

## 🐛 **Debugging Guide**

### **Console Output Issues** 
⚠️ **Known Issue**: Xcode console may not show `print()` statements.

**Troubleshooting Steps**:
1. **Check Console Panel**: View → Debug Area → Show Debug Area (Cmd+Shift+Y)
2. **Verify Console Tab**: Click "Console" tab in bottom panel
3. **Clear Filters**: Look for filter buttons in console toolbar
4. **Alternative Logging**: Try `NSLog()` instead of `print()`

**Example Debug Code**:
```swift
// Instead of: print("Debug message")
NSLog("🎵 Debug message: %@", "value")

// Or use OSLog for production
import OSLog
let logger = Logger(subsystem: "com.yourcompany.SheetNoteLabels", category: "OMR")
logger.info("Analysis started")
```

### **Visual Debugging**

#### **Current Debug Features**
- **Green Status Box**: Top-right corner shows "X notes" detected
- **Blue Circles**: Show detected note positions (when implemented)  
- **Yellow Labels**: Show note names with background circles

#### **Adding Debug Visuals**
```swift
// In OverlayRenderer.swift - add debug markers
context.cgContext.setFillColor(UIColor.red.cgColor)
context.cgContext.fill(CGRect(x: debugX, y: debugY, width: 10, height: 10))
```

### **Common Issues**

#### **"Cannot find 'PreviewView' in scope"**
**Cause**: New Swift files not included in Xcode project
**Solution**: 
```bash
# Regenerate project to include all .swift files
xcodegen
# Then reopen Xcode
```

#### **No Notes Detected**
**Debugging Steps**:
1. Check `result.detectedNotes.count` in green status box
2. Verify mock note creation in `createMockNotes()`
3. Add debug prints to `HeuristicOMRDetector.detectNotes()`

#### **Labels Not Visible**
**Debugging Steps**:
1. Check if labels are positioned off-screen
2. Verify `OverlayRenderer` is being called
3. Test with fixed positions first, then dynamic positioning

## 🔄 **Git Workflow**

### **Branch Strategy**
- **main**: Stable, deployable code
- **feature/[name]**: New features and enhancements
- **bugfix/[name]**: Bug fixes
- **hotfix/[name]**: Critical production fixes

### **Commit Guidelines**
```bash
# Good commit messages
git commit -m "Fix note label alignment to position below noteheads

- Update OverlayRenderer to use note.center coordinates  
- Remove hardcoded yPos calculation
- Add bounds checking for off-screen labels
- Fixes #1

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### **Pull Request Process**
1. Create feature branch from main
2. Make changes with tests
3. Update documentation if needed
4. Create PR with description linking to issues
5. Review and merge after approval

## 🧪 **Testing Strategy**

### **Unit Tests (Current)**
- **PitchMapper Tests**: Verify note position to pitch conversion
- **NoteLetter Tests**: Validate semitone offset calculations
- **Clef Mapping Tests**: Test treble and bass clef positioning

### **Integration Tests (Needed)**
- End-to-end OMR pipeline testing
- Image processing with various formats
- Export functionality validation

### **UI Tests (Future)**
- Navigation flow testing
- Camera permissions handling  
- Share sheet functionality

### **Performance Tests**
- Memory usage during large image processing
- Analysis time benchmarks
- UI responsiveness under load

## 📝 **Code Style Guidelines**

### **Swift Style**
- Follow Apple's Swift API Design Guidelines
- Use SwiftUI best practices for view composition
- Prefer `@MainActor` for UI-related ViewModels
- Include comprehensive inline documentation

### **Documentation Standards**
```swift
/// Maps a Y-coordinate position to a musical pitch within a staff
/// 
/// - Parameters:
///   - y: The Y-coordinate in image space (0 = top of image)
///   - staff: Staff information including top position and line spacing
/// - Returns: Musical pitch with letter name and octave
/// - Note: Positions are rounded to nearest staff line or space
static func mapYCoordinateToPitch(_ y: CGFloat, in staff: StaffInfo) -> NotePitch {
    // Implementation...
}
```

### **Error Handling**
```swift
// Prefer structured error handling
enum OMRError: LocalizedError {
    case noStaffDetected
    case imageProcessingFailed
    
    var errorDescription: String? {
        switch self {
        case .noStaffDetected: return "No musical staff detected in image"
        case .imageProcessingFailed: return "Failed to process the image"
        }
    }
}

// Use Result types for complex operations
func detectNotes(in image: UIImage) -> Result<OMRResult, OMRError> {
    // Implementation...
}
```

## 🚀 **Release Process**

### **Version Numbering**
- **Major.Minor.Patch** (e.g., 1.0.0, 1.1.0, 1.1.1)
- **Major**: Breaking changes, major new features
- **Minor**: New features, backwards compatible
- **Patch**: Bug fixes, small improvements

### **Release Checklist**
- [ ] All unit tests passing
- [ ] Manual testing on physical device
- [ ] Performance testing with large images
- [ ] Update version in Info.plist
- [ ] Update CHANGELOG.md
- [ ] Create GitHub release with notes
- [ ] Tag release in git

### **Distribution**
- **Development**: Direct Xcode deployment
- **Beta**: TestFlight (future)
- **Production**: App Store (future)

## 🤝 **Contributing**

### **Getting Started**
1. Fork the repository
2. Clone your fork locally
3. Create feature branch: `git checkout -b feature/your-feature-name`
4. Make changes with appropriate tests
5. Ensure all tests pass: `Cmd+U` in Xcode
6. Submit pull request

### **Issue Reporting**
- Use GitHub Issues for bug reports and feature requests
- Include device info, iOS version, and reproduction steps
- Attach sample images for OMR-related issues

### **Code Review Guidelines**
- All code must be reviewed before merging
- Focus on correctness, performance, and maintainability
- Provide constructive feedback with suggestions
- Approve only when confident in changes

## 📚 **Resources**

### **Apple Documentation**
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [Core Image](https://developer.apple.com/documentation/coreimage)  
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [PhotosUI](https://developer.apple.com/documentation/photosui)

### **Computer Vision Resources**
- [OpenCV OMR Techniques](https://docs.opencv.org/)
- [Optical Music Recognition Research Papers](https://arxiv.org/search/?query=optical+music+recognition)
- [Music21 (Python) for Music Theory](https://web.mit.edu/music21/)

### **Music Theory References**
- [Clef and Staff Positioning](https://en.wikipedia.org/wiki/Clef)
- [Key Signatures Reference](https://en.wikipedia.org/wiki/Key_signature)
- [Note Naming Conventions](https://en.wikipedia.org/wiki/Scientific_pitch_notation)

---

**Last Updated**: August 2025  
**Maintainer**: Development Team  
**Questions**: Create GitHub issue or discussion