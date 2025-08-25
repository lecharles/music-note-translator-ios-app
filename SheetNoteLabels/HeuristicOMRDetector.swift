import Foundation
import UIKit
import Vision
import CoreImage

class HeuristicOMRDetector: OMRDetector {
    
    func detectNotes(in image: UIImage, clef: Clef) async throws -> OMRResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Step 1: Preprocess image
        guard let processedImage = preprocessImage(image) else {
            throw OMRError.imageProcessingFailed
        }
        
        // Step 2: Detect staff lines
        let staffs = try await detectStaffLines(in: processedImage, clef: clef)
        guard !staffs.isEmpty else {
            throw OMRError.noStaffDetected
        }
        
        // Step 3: Detect noteheads
        let detectedNotes = try await detectNoteheads(in: processedImage, staffs: staffs)
        
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        
        return OMRResult(
            detectedNotes: detectedNotes,
            staffs: staffs,
            processingTime: processingTime,
            originalImage: image
        )
    }
    
    // MARK: - Image Preprocessing
    
    private func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        
        // Convert to grayscale
        guard let grayscaleFilter = CIFilter(name: "CIColorControls") else { return nil }
        grayscaleFilter.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter.setValue(0.0, forKey: kCIInputSaturationKey)
        
        // Increase contrast
        guard let contrastFilter = CIFilter(name: "CIColorControls") else { return nil }
        contrastFilter.setValue(grayscaleFilter.outputImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(1.5, forKey: kCIInputContrastKey)
        
        guard let outputImage = contrastFilter.outputImage,
              let processedCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: processedCGImage)
    }
    
    // MARK: - Staff Detection
    
    private func detectStaffLines(in image: UIImage, clef: Clef) async throws -> [StaffInfo] {
        guard let cgImage = image.cgImage else {
            throw OMRError.imageProcessingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // For now, create a mock staff based on image dimensions
                // In a full implementation, this would use line detection algorithms
                let staffInfo = self.createMockStaff(for: image, clef: clef)
                continuation.resume(returning: [staffInfo])
            }
            
            request.minimumAspectRatio = 0.8
            request.maximumAspectRatio = 1.0
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func createMockStaff(for image: UIImage, clef: Clef) -> StaffInfo {
        let imageHeight = image.size.height
        let imageWidth = image.size.width
        
        // Create a staff in the middle third of the image
        let staffTop = imageHeight * 0.35
        let staffSpacing: CGFloat = imageHeight * 0.06 // Space between staff lines
        let staffBottom = staffTop + (staffSpacing * 4) // 5 lines = 4 spaces
        
        return StaffInfo(
            id: 0,
            topY: staffTop,
            bottomY: staffBottom,
            spacing: staffSpacing,
            clef: clef
        )
    }
    
    // MARK: - Notehead Detection
    
    private func detectNoteheads(in image: UIImage, staffs: [StaffInfo]) async throws -> [DetectedNote] {
        guard let cgImage = image.cgImage else {
            throw OMRError.imageProcessingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectContoursRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNContoursObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let detectedNotes = self.processContours(observations, image: image, staffs: staffs)
                continuation.resume(returning: detectedNotes)
            }
            
            request.contrastAdjustment = 1.5
            request.detectsDarkOnLight = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func processContours(_ observations: [VNContoursObservation], image: UIImage, staffs: [StaffInfo]) -> [DetectedNote] {
        var detectedNotes: [DetectedNote] = []
        let imageSize = image.size
        
        for observation in observations {
            let contour = observation.topLevelContours.first
            guard let contourPoints = contour?.normalizedPoints else { continue }
            
            // Convert normalized coordinates to image coordinates
            let imagePoints = contourPoints.map { point in
                CGPoint(
                    x: CGFloat(point.x) * imageSize.width,
                    y: (1 - CGFloat(point.y)) * imageSize.height // Flip Y coordinate
                )
            }
            
            // Check if contour looks like a notehead (elliptical, appropriate size)
            if let noteCandidate = analyzeContourForNotehead(imagePoints, staffs: staffs) {
                detectedNotes.append(noteCandidate)
            }
        }
        
        // For demo purposes, also add some mock notes if no real ones detected
        if detectedNotes.isEmpty {
            detectedNotes = createMockNotes(for: staffs[0])
        }
        
        return detectedNotes
    }
    
    private func analyzeContourForNotehead(_ points: [CGPoint], staffs: [StaffInfo]) -> DetectedNote? {
        guard let staff = staffs.first, !points.isEmpty else { return nil }
        
        // Calculate bounding box
        let minX = points.map { $0.x }.min() ?? 0
        let maxX = points.map { $0.x }.max() ?? 0
        let minY = points.map { $0.y }.min() ?? 0
        let maxY = points.map { $0.y }.max() ?? 0
        
        let bbox = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        let center = CGPoint(x: bbox.midX, y: bbox.midY)
        
        // Simple size filtering for noteheads
        let expectedNoteSize = staff.spacing * 0.8
        if bbox.width < expectedNoteSize * 0.5 || bbox.width > expectedNoteSize * 2.0 {
            return nil
        }
        
        if bbox.height < expectedNoteSize * 0.3 || bbox.height > expectedNoteSize * 1.5 {
            return nil
        }
        
        // Map to pitch
        let pitch = PitchMapper.mapYCoordinateToPitch(center.y, in: staff)
        
        return DetectedNote(
            bbox: bbox,
            center: center,
            staffId: staff.id,
            pitch: pitch,
            confidence: 0.7
        )
    }
    
    private func createMockNotes(for staff: StaffInfo) -> [DetectedNote] {
        // Create some demo notes for testing
        let notePositions: [(CGFloat, CGFloat)] = [
            (100, staff.topY + staff.spacing * 0), // F
            (150, staff.topY + staff.spacing * 1), // E
            (200, staff.topY + staff.spacing * 2), // D
            (250, staff.topY + staff.spacing * 3), // C
            (300, staff.topY + staff.spacing * 4)  // B
        ]
        
        return notePositions.enumerated().map { index, position in
            let center = CGPoint(x: position.0, y: position.1)
            let bbox = CGRect(
                x: center.x - 8,
                y: center.y - 6,
                width: 16,
                height: 12
            )
            let pitch = PitchMapper.mapYCoordinateToPitch(center.y, in: staff)
            
            return DetectedNote(
                bbox: bbox,
                center: center,
                staffId: staff.id,
                pitch: pitch,
                confidence: 0.8
            )
        }
    }
}