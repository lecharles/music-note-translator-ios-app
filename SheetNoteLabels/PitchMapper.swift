import Foundation
import UIKit

struct PitchMapper {
    
    static func mapYCoordinateToPitch(_ y: CGFloat, in staff: StaffInfo) -> NotePitch {
        let staffSpacing = staff.spacing
        let staffTop = staff.topY
        
        // Calculate position relative to staff (0 = top line, 4 = bottom line)
        let relativeY = y - staffTop
        let lineSpacePosition = relativeY / (staffSpacing / 2)
        let roundedPosition = Int(round(lineSpacePosition))
        
        return pitchForPosition(roundedPosition, clef: staff.clef)
    }
    
    private static func pitchForPosition(_ position: Int, clef: Clef) -> NotePitch {
        switch clef {
        case .treble:
            return treblePitchForPosition(position)
        case .bass:
            return bassPitchForPosition(position)
        }
    }
    
    private static func treblePitchForPosition(_ position: Int) -> NotePitch {
        // Treble clef: position 0 = F5, 1 = E5, 2 = D5, 3 = C5, 4 = B4, etc.
        let baseOctave = 5
        let letters: [NoteLetter] = [.F, .E, .D, .C, .B, .A, .G]
        
        let adjustedPosition = position
        let letterIndex = adjustedPosition % 7
        let octaveOffset = adjustedPosition / 7
        
        let letter = letters[abs(letterIndex) % 7]
        let octave = baseOctave - octaveOffset
        
        return NotePitch(letter: letter, octave: octave, accidental: nil)
    }
    
    private static func bassPitchForPosition(_ position: Int) -> NotePitch {
        // Bass clef: position 0 = A3, 1 = G3, 2 = F3, 3 = E3, 4 = D3, etc.
        let baseOctave = 3
        let letters: [NoteLetter] = [.A, .G, .F, .E, .D, .C, .B]
        
        let adjustedPosition = position
        let letterIndex = adjustedPosition % 7
        let octaveOffset = adjustedPosition / 7
        
        let letter = letters[abs(letterIndex) % 7]
        let octave = baseOctave - octaveOffset
        
        return NotePitch(letter: letter, octave: octave, accidental: nil)
    }
}