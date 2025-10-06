import Foundation
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var cuePeripheral: CBPeripheral?
    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?
    
    // Bluefruit UART UUIDs
    private let uartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    private let txUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    private let rxUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    
    // Published data
    @Published var isConnected = false
    @Published var yaw: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var straightness: String = "Waiting..."
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - BLE Setup
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("🔍 Scanning for CueStick...")
            centralManager.scanForPeripherals(withServices: [uartServiceUUID], options: nil)
        } else {
            print("⚠️ Bluetooth not ready: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found \(peripheral.name ?? "Unknown")")
        if peripheral.name?.contains("Cue") == true {
            cuePeripheral = peripheral
            cuePeripheral?.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to CueStick")
        isConnected = true
        peripheral.discoverServices([uartServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            if service.uuid == uartServiceUUID {
                peripheral.discoverCharacteristics([txUUID, rxUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == txUUID {
                txCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("TX characteristic ready")
            } else if characteristic.uuid == rxUUID {
                rxCharacteristic = characteristic
                print("RX characteristic ready")
            }
        }
    }
    
    // MARK: - Data Handling
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value,
              let text = String(data: data, encoding: .utf8)
        else { return }

        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = cleaned.split(separator: ",")
        
        if components.count == 2,
           let yawVal = Double(components[0]),
           let pitchVal = Double(components[1]) {
            DispatchQueue.main.async {
                self.yaw = yawVal
                self.pitch = pitchVal
                self.checkStraightness()
            }
        } else if cleaned.contains("RESET_OK") {
            DispatchQueue.main.async {
                self.straightness = "🟢 Reset Complete"
            }
        }
    }
    
    func sendCommand(_ command: String) {
        guard let peripheral = cuePeripheral,
              let characteristic = rxCharacteristic else { return }
        let data = command.data(using: .utf8)!
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        print("📤 Sent: \(command)")
    }
    
    // MARK: - Straightness Logic
    private func checkStraightness() {
        if abs(yaw) < 5 {
            straightness = "✅ Straight Stroke"
        } else if yaw > 5 {
            straightness = "↩️ Tilted Left"
        } else {
            straightness = "↪️ Tilted Right"
        }
    }
}
