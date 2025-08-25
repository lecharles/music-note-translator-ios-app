# Technical Issues & Improvements

This document tracks specific technical issues, bugs, and improvements needed for the Sheet Note Labels iOS app.

## 🔥 **Critical Issues (Fix Immediately)**

### **Issue #1: Note Label Alignment** 
**Status**: 🔴 Critical Bug  
**Priority**: P0 (Blocks core functionality)

**Problem**: Note labels (F, E, D, B, G) appear in a horizontal strip at the bottom of the image instead of being positioned directly below their corresponding noteheads.

**Root Cause**: 
- Labels are being positioned at fixed coordinates rather than using detected note positions
- Current implementation uses `yPos = size.height * 0.75` which forces all labels to bottom area

**Expected Behavior**: Each note letter should appear 6-8 pixels directly below its corresponding notehead

**Technical Tasks**:
- [ ] Fix positioning calculation in `OverlayRenderer.swift` to use `note.center.x` and `note.center.y + offset`
- [ ] Remove hardcoded `yPos` calculation  
- [ ] Handle edge cases where labels might be positioned off-screen
- [ ] Test with different image sizes and aspect ratios
- [ ] Add bounds checking to prevent labels from being drawn outside image bounds

**Files to Modify**:
- `SheetNoteLabels/OverlayRenderer.swift` (lines 69-87)

---

## ⚠️ **High Priority Issues**

### **Issue #2: Mock Staff Detection**
**Status**: 🟠 Technical Debt  
**Priority**: P1 (Affects accuracy)

**Problem**: Staff detection uses estimated positions rather than actual line detection from the image.

**Current Implementation**: `createMockStaff()` in `HeuristicOMRDetector.swift` creates staff at fixed percentages of image height.

**Improvement Plan**:
- [ ] Implement Hough line detection for horizontal staff lines
- [ ] Calculate actual staff spacing and vertical positioning from detected lines
- [ ] Add validation for detected staff geometry (5 parallel lines, consistent spacing)
- [ ] Handle multiple staff systems in one image
- [ ] Fall back to mock staff if detection fails

**Files to Modify**:
- `SheetNoteLabels/HeuristicOMRDetector.swift` (lines 75-90)

---

### **Issue #3: Mock Note Detection** 
**Status**: 🟠 Technical Debt  
**Priority**: P1 (Affects functionality)

**Problem**: Note detection uses 5 hardcoded positions instead of actual computer vision.

**Current Implementation**: `createMockNotes()` generates notes at fixed X positions with calculated Y positions.

**Improvement Plan**:
- [ ] Tune Vision contour detection parameters for better notehead recognition
- [ ] Add size and shape filtering to distinguish noteheads from other shapes
- [ ] Implement stem detection and note grouping
- [ ] Handle different note types (quarter, half, whole, eighth notes)
- [ ] Add confidence scoring for detected notes

**Files to Modify**:
- `SheetNoteLabels/HeuristicOMRDetector.swift` (lines 214-239)

---

## 🔧 **Medium Priority Issues**

### **Issue #4: Console Debug Output**
**Status**: 🟡 Development Blocker  
**Priority**: P2 (Affects debugging)

**Problem**: Debug `print()` statements don't appear in Xcode console, making development difficult.

**Current Status**: Console panel is visible but shows no output despite multiple `print()` calls throughout codebase.

**Investigation Needed**:
- [ ] Check Xcode console settings and filters
- [ ] Verify debug/release build configuration  
- [ ] Test with `NSLog()` instead of `print()`
- [ ] Consider implementing proper logging framework (OSLog)
- [ ] Document debugging workflow for future developers

**Files Affected**: All files with `print()` statements

---

### **Issue #5: Single Staff Limitation**
**Status**: 🟡 Feature Gap  
**Priority**: P2 (Limits use cases)

**Problem**: Only processes the first detected staff system, ignoring multiple staves in piano music, orchestral scores, etc.

**Enhancement Plan**:
- [ ] Modify staff detection to find all staff systems in image
- [ ] Update data models to handle multiple staves
- [ ] Implement staff-aware note detection
- [ ] Design UI to handle multiple staff results
- [ ] Add staff selection/filtering options

---

## 🎵 **Music Theory & Features**

### **Issue #6: Clef Detection**
**Status**: 🔵 Enhancement  
**Priority**: P3 (User Experience)

**Current State**: Hardcoded to treble clef in `analyzeImage()` call.

**Enhancement Plan**:
- [ ] Train or implement clef symbol recognition
- [ ] Add bass clef, alto clef, tenor clef support  
- [ ] Create SettingsView for manual clef selection
- [ ] Update PitchMapper tests for all clef types
- [ ] Handle mixed clefs in multi-staff music

---

### **Issue #7: Key Signature Support**
**Status**: 🔵 Enhancement  
**Priority**: P3 (Music Theory)

**Current State**: All notes displayed as natural (C, D, E, F, G, A, B).

**Enhancement Plan**:
- [ ] Detect sharp/flat symbols at beginning of staff (key signature)
- [ ] Implement key signature to pitch mapping logic
- [ ] Update note labeling to show correct pitch names (F# instead of F)
- [ ] Add common key signature database
- [ ] Handle transposing instruments

---

### **Issue #8: Accidental Detection**
**Status**: 🔵 Enhancement  
**Priority**: P3 (Music Theory)

**Current State**: Individual sharp, flat, natural symbols not detected.

**Enhancement Plan**:
- [ ] Train Vision model to recognize accidental symbols
- [ ] Implement accidental-to-notehead association logic
- [ ] Update pitch calculation to include accidentals
- [ ] Handle accidental carry-over rules within measures
- [ ] Display accidentals in note labels (C#, Bb, etc.)

---

## 🚀 **Advanced Features**

### **Issue #9: Core ML Integration**
**Status**: 🔵 Future Enhancement  
**Priority**: P4 (Performance)

**Vision**: Replace heuristic detection with trained machine learning model.

**Research Needed**:
- [ ] Evaluate existing music notation datasets
- [ ] Design custom model architecture for OMR
- [ ] Create training pipeline and data augmentation
- [ ] Benchmark against current Vision-based approach
- [ ] Implement model switching (heuristic vs ML)

---

### **Issue #10: Real-time Camera Processing**
**Status**: 🔵 Future Enhancement  
**Priority**: P4 (User Experience)

**Vision**: Live camera feed with real-time note detection overlay.

**Technical Challenges**:
- [ ] Optimize detection pipeline for 30fps processing
- [ ] Handle camera motion and focus changes
- [ ] Design non-intrusive overlay UI for live view
- [ ] Implement frame-by-frame result caching
- [ ] Handle device orientation changes

---

## 🐛 **Known Bugs**

### **Bug #1: PDF to Image Conversion**
**Status**: 🟡 Minor Bug  
**Files**: `CaptureViewModel.swift` (lines 24-54)

**Issue**: PDF conversion may fail silently for some PDF formats, falling back to demo placeholder without user notification.

**Fix Plan**:
- [ ] Add error handling and user feedback for PDF conversion failures
- [ ] Support different PDF page orientations
- [ ] Test with various PDF creation tools (Finale, Sibelius, MuseScore)

---

### **Bug #2: Image Scaling in Preview**
**Status**: 🟡 Minor Bug  
**Files**: `PreviewView.swift` (lines 15-25)

**Issue**: Very large images may not scale properly in ScrollView, causing performance issues.

**Fix Plan**:
- [ ] Implement image downscaling for preview display
- [ ] Maintain full resolution for export functionality
- [ ] Add zoom controls and pan gestures

---

## 📊 **Performance Issues**

### **Performance #1: Large Image Processing**
**Status**: 🟡 Optimization Opportunity

**Issue**: Images larger than 4K may cause memory pressure and slow processing.

**Optimization Plan**:
- [ ] Implement image downscaling before Vision processing
- [ ] Use tiled processing for very large images
- [ ] Add progress indicators for long operations
- [ ] Profile memory usage during analysis

---

### **Performance #2: Background Processing**
**Status**: 🟡 Optimization Opportunity  

**Issue**: Analysis currently blocks UI thread during processing.

**Current**: `DispatchQueue.global(qos: .userInitiated).async` in PreviewView
**Improvement**: Move all OMR processing to background with proper progress reporting

---

## 🧪 **Testing Gaps**

### **Testing #1: Integration Tests**
**Status**: Missing test coverage for end-to-end workflows

**Needed Tests**:
- [ ] Image capture → analysis → preview → export workflow
- [ ] Different image formats and sizes
- [ ] Error handling and recovery scenarios
- [ ] Performance benchmarks on target devices

### **Testing #2: UI Tests**
**Status**: No automated UI testing currently implemented

**Needed Tests**:
- [ ] Navigation flow testing
- [ ] Share sheet functionality
- [ ] Settings persistence
- [ ] Accessibility testing

---

## 📱 **Device Compatibility**

### **iOS Version Support**
- **Current**: iOS 17.0+ required
- **Consideration**: Lower to iOS 16.0 for wider device support
- **Blocker**: PhotosUI and Vision framework features used

### **Device Performance**
- **Tested**: iPhone 15 Pro (A17 Pro)
- **Needs Testing**: iPhone 12 mini, iPad variants, older devices
- **Target**: <3 second analysis on iPhone 13 or newer

---

**Last Updated**: August 2025  
**Total Open Issues**: 10 Critical/High + 15 Enhancement/Future  
**Next Review**: After v1.1 alignment fixes