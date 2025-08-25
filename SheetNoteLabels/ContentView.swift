import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Sheet Note Labels")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Capture sheet music and label notes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: CaptureView()) {
                    Text("Start Labeling")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Home")
        }
    }
}