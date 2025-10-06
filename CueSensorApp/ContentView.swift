import SwiftUI

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🎱 Cue Straight")
                .font(.largeTitle)
                .bold()
                .padding(.top, 30)
            
            Text(bleManager.isConnected ? "✅ Connected to CueStick" : "🔄 Connecting...")
                .font(.headline)
            
            VStack(spacing: 8) {
                Text("Yaw: \(bleManager.yaw, specifier: "%.2f")°")
                Text("Pitch: \(bleManager.pitch, specifier: "%.2f")°")
            }
            .font(.title3)
            .padding()
            
            Text(bleManager.straightness)
                .font(.title2)
                .bold()
                .foregroundColor(.blue)
                .padding(.bottom, 30)
            
            Button("Reset Baseline") {
                bleManager.sendCommand("R")
            }
            .font(.title3)
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            Spacer()
        }
        .padding()
    }
}
