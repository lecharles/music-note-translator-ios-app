import Foundation
import UIKit

// MARK: - Core Data Models

struct DetectedNote {
    let bbox: CGRect
    let center: CGPoint
    let staffId: Int
    let pitch: NotePitch
    let confidence: Float
}

struct NotePitch {
    let letter: NoteLetter
    let octave: Int
    let accidental: Accidental?
}

enum NoteLetter: String, CaseIterable {
    case C, D, E, F, G, A, B
    
    var semitoneOffset: Int {
        switch self {
        case .C: return 0
        case .D: return 2
        case .E: return 4
        case .F: return 5
        case .G: return 7
        case .A: return 9
        case .B: return 11
        }
    }
}

enum Accidental: String {
    case sharp = "#"
    case flat = "♭"
    case natural = "♮"
}

enum Clef {
    case treble
    case bass
    
    var referencePitch: NotePitch {
        switch self {
        case .treble:
            return NotePitch(letter: .G, octave: 4, accidental: nil) // G4 on second line
        case .bass:
            return NotePitch(letter: .F, octave: 3, accidental: nil) // F3 on fourth line
        }
    }
}

struct StaffInfo {
    let id: Int
    let topY: CGFloat
    let bottomY: CGFloat
    let spacing: CGFloat // Distance between staff lines
    let clef: Clef
}

struct OMRResult {
    let detectedNotes: [DetectedNote]
    let staffs: [StaffInfo]
    let processingTime: TimeInterval
    let originalImage: UIImage
}

// MARK: - OMR Protocol

protocol OMRDetector {
    func detectNotes(in image: UIImage, clef: Clef) async throws -> OMRResult
}

// MARK: - Analysis Errors

enum OMRError: LocalizedError {
    case noStaffDetected
    case imageProcessingFailed
    case insufficientContrast
    
    var errorDescription: String? {
        switch self {
        case .noStaffDetected:
            return "No musical staff detected in the image"
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .insufficientContrast:
            return "Image contrast is too low for reliable detection"
        }
    }
}