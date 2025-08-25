import XCTest
@testable import SheetNoteLabels

final class SheetNoteLabelsTests: XCTestCase {
    
    func testNoteLetter() {
        XCTAssertEqual(NoteLetter.C.semitoneOffset, 0)
        XCTAssertEqual(NoteLetter.D.semitoneOffset, 2)
        XCTAssertEqual(NoteLetter.E.semitoneOffset, 4)
        XCTAssertEqual(NoteLetter.F.semitoneOffset, 5)
        XCTAssertEqual(NoteLetter.G.semitoneOffset, 7)
        XCTAssertEqual(NoteLetter.A.semitoneOffset, 9)
        XCTAssertEqual(NoteLetter.B.semitoneOffset, 11)
    }
    
    func testTrebleClefPitchMapping() {
        // Create a mock treble clef staff
        let staff = StaffInfo(
            id: 0,
            topY: 100,
            bottomY: 180,
            spacing: 20, // 20 pixels between staff lines
            clef: .treble
        )
        
        // Test staff line positions
        // Top line (F5)
        let f5 = PitchMapper.mapYCoordinateToPitch(100, in: staff)
        XCTAssertEqual(f5.letter, .F)
        XCTAssertEqual(f5.octave, 5)
        
        // Second line (D5)
        let d5 = PitchMapper.mapYCoordinateToPitch(120, in: staff)
        XCTAssertEqual(d5.letter, .D)
        XCTAssertEqual(d5.octave, 5)
        
        // Middle line (B4)
        let b4 = PitchMapper.mapYCoordinateToPitch(160, in: staff)
        XCTAssertEqual(b4.letter, .B)
        XCTAssertEqual(b4.octave, 4)
    }
    
    func testBassClefPitchMapping() {
        // Create a mock bass clef staff  
        let staff = StaffInfo(
            id: 0,
            topY: 100,
            bottomY: 180,
            spacing: 20,
            clef: .bass
        )
        
        // Test staff line positions
        // Top line (A3)
        let a3 = PitchMapper.mapYCoordinateToPitch(100, in: staff)
        XCTAssertEqual(a3.letter, .A)
        XCTAssertEqual(a3.octave, 3)
        
        // Fourth line (F3) 
        let f3 = PitchMapper.mapYCoordinateToPitch(160, in: staff)
        XCTAssertEqual(f3.letter, .F)
        XCTAssertEqual(f3.octave, 3)
    }
    
    func testStaffSpaceMapping() {
        let staff = StaffInfo(
            id: 0,
            topY: 100,
            bottomY: 180,
            spacing: 20,
            clef: .treble
        )
        
        // Test space between first and second line (E5)
        let e5 = PitchMapper.mapYCoordinateToPitch(110, in: staff)
        XCTAssertEqual(e5.letter, .E)
        XCTAssertEqual(e5.octave, 5)
    }
}