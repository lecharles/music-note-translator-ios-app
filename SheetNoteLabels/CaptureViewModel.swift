import SwiftUI
import PhotosUI
import Foundation
import CoreGraphics

@MainActor
class CaptureViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var isAnalyzing = false
    @Published var analysisResults: String = ""
    @Published var omrResult: OMRResult?
    
    func loadSelectedImage() {
        Task {
            if let selectedItem = selectedItem {
                if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
    
    func loadDemoImage() {
        // Try to load the unlabeled demo PDF and convert to UIImage
        if let path = Bundle.main.path(forResource: "sheet-music-example-with-notes-unlabelled", ofType: "pdf"),
           let pdfImage = convertPDFToImage(path: path) {
            selectedImage = pdfImage
        } else {
            // Fallback to placeholder
            selectedImage = createDemoPlaceholderImage()
        }
    }
    
    private func convertPDFToImage(path: String) -> UIImage? {
        guard let url = URL(string: "file://\(path)"),
              let document = CGPDFDocument(url as CFURL),
              let page = document.page(at: 1) else {
            return nil
        }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        let image = renderer.image { context in
            UIColor.white.set()
            context.fill(pageRect)
            
            context.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            context.cgContext.drawPDFPage(page)
        }
        
        return image
    }
    
    func analyzeImage() {
        guard let image = selectedImage else { return }
        
        isAnalyzing = true
        
        Task {
            do {
                let detector = HeuristicOMRDetector()
                let result = try await detector.detectNotes(in: image, clef: .treble)
                
                isAnalyzing = false
                
                // Store result for navigation to preview
                omrResult = result
                
                // Display results summary
                var resultText = "Analysis complete! Found \(result.detectedNotes.count) notes in \(String(format: "%.2f", result.processingTime)) seconds\n\n"
                for (index, note) in result.detectedNotes.enumerated() {
                    resultText += "\(index + 1). \(note.pitch.letter.rawValue)\(note.pitch.octave) at (\(Int(note.center.x)), \(Int(note.center.y)))\n"
                }
                analysisResults = resultText
                
                // Also print to console
                print(resultText)
            } catch {
                isAnalyzing = false
                analysisResults = "Analysis failed: \(error.localizedDescription)"
                print("Analysis failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func createDemoPlaceholderImage() -> UIImage {
        let size = CGSize(width: 400, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            UIColor.black.setStroke()
            context.cgContext.setLineWidth(2)
            
            // Draw simple staff lines
            for i in 0..<5 {
                let y = 50 + (i * 20)
                context.cgContext.move(to: CGPoint(x: 20, y: y))
                context.cgContext.addLine(to: CGPoint(x: 380, y: y))
                context.cgContext.strokePath()
            }
            
            // Draw some simple note circles
            UIColor.black.setFill()
            let notePositions = [(100, 70), (150, 50), (200, 90), (250, 70)]
            for (x, y) in notePositions {
                context.cgContext.fillEllipse(in: CGRect(x: x-5, y: y-5, width: 10, height: 10))
            }
        }
    }
}