import SwiftUI
import PhotosUI

struct CaptureView: View {
    @StateObject private var viewModel = CaptureViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                
                Button(viewModel.isAnalyzing ? "Analyzing..." : "Analyze Image") {
                    viewModel.analyzeImage()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(viewModel.isAnalyzing ? Color.gray : Color.green)
                .cornerRadius(10)
                .disabled(viewModel.isAnalyzing)
                
                if viewModel.isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                
                if !viewModel.analysisResults.isEmpty {
                    VStack(spacing: 12) {
                        ScrollView {
                            Text(viewModel.analysisResults)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 150)
                        
                        if let result = viewModel.omrResult {
                            NavigationLink(destination: PreviewView(result: result)) {
                                Text("View Labeled Image")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 15) {
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Button("Use Demo Image") {
                        viewModel.loadDemoImage()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Capture")
        .onChange(of: viewModel.selectedItem) { _ in
            viewModel.loadSelectedImage()
        }
    }
}