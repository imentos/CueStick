# CueSensorApp

CueSensorApp is an iOS application that helps pool players improve their cue stick technique using real-time sensor feedback. The app connects to a CueStick device via Bluetooth and provides instant feedback on stroke straightness.

## Features

- 🎯 Real-time stroke analysis
- 🎵 Audio feedback for stroke deviation
- 📱 Bluetooth connectivity with CueStick device
- 🔄 Baseline calibration
- 📊 Yaw and pitch angle measurements

## Requirements

- iOS 14.0 or later
- Xcode 13.0 or later
- CueStick Bluetooth sensor device
- iPhone with Bluetooth capability

## Installation

1. Clone the repository
2. Open `CueSensorApp.xcodeproj` in Xcode
3. Build and run the project on your iOS device

## Usage

1. **Connect Device**: 
   - Power on your CueStick device
   - Launch the app
   - Wait for automatic connection

2. **Calibrate**:
   - Place the cue stick on a flat surface
   - Tap "Reset Baseline" to calibrate

3. **Practice**:
   - Audio feedback indicates deviation from straight
   - Visual feedback shows exact angle measurements
   - Real-time straightness status updates

## Technical Details

### Bluetooth Specifications
- Service UUID: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
- TX Characteristic: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E
- RX Characteristic: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E

### Key Components
- `BLEManager`: Handles Bluetooth communication and sensor data processing
- `ContentView`: Main UI implementation and audio feedback
- Built with SwiftUI and Combine frameworks
- Real-time audio feedback using `AVAudioEngine`

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

MIT License

## Contact

For questions and support, please open an issue in the GitHub repository.