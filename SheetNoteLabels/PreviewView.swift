import SwiftUI

struct PreviewView: View {
    let result: OMRResult
    @State private var labeledImage: UIImage?
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            if let labeledImage = labeledImage {
                ScrollView([.horizontal, .vertical]) {
                    Image(uiImage: labeledImage)
                        .resizable()
                        .scaledToFit()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                
                VStack(spacing: 12) {
                    Text("Found \(result.detectedNotes.count) notes")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        Button("Export PDF") {
                            exportToPDF()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        
                        Button("Share Image") {
                            shareImage()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
            } else {
                ProgressView("Generating labeled image...")
                    .padding()
            }
        }
        .navigationTitle("Labeled Sheet Music")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateLabeledImage()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareURL = shareURL {
                ShareSheet(activityItems: [shareURL])
            } else if let labeledImage = labeledImage {
                ShareSheet(activityItems: [labeledImage])
            }
        }
    }
    
    private func generateLabeledImage() {
        print("DEBUG: Starting to generate labeled image with \(result.detectedNotes.count) notes")
        
        DispatchQueue.global(qos: .userInitiated).async {
            print("DEBUG: About to call OverlayRenderer")
            // Use larger font size for better visibility
            let rendered = OverlayRenderer.renderLabelsOnImage(result, fontSize: 28)
            print("DEBUG: OverlayRenderer completed, image size: \(rendered.size)")
            
            DispatchQueue.main.async {
                print("DEBUG: Setting labeled image on main thread")
                self.labeledImage = rendered
            }
        }
    }
    
    private func exportToPDF() {
        if let pdfURL = OverlayRenderer.exportToPDF(result, fileName: "sheet_music_labeled") {
            shareURL = pdfURL
            showingShareSheet = true
        }
    }
    
    private func shareImage() {
        shareURL = nil
        showingShareSheet = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}