#include <bluefruit.h>
#include <Wire.h>
#include <LSM6DS3.h>  // Use "LSM6DS3.h" if "Adafruit_LSM6DS3TRC.h" not available
// #include <Adafruit_Sensor.h>

LSM6DS3 imu(I2C_MODE, 0x6A);

// BLE UART service
BLEUart bleuart;

float yaw = 0, pitch = 0, roll = 0;
float yawOffset = 0;
unsigned long lastTime = 0;

// Complementary filter weights
float alpha = 0.98;

void setup() {
  Serial.begin(115200);
  delay(2000);
  Serial.println("CueStick BLE IMU starting...");

  Wire.begin();
  if (imu.begin() != 0) {
    Serial.println("Failed to find LSM6DS3!");
    while (1);
  }
  Serial.println("LSM6DS3 initialized!");

  // Setup BLE
  Bluefruit.begin();
  Bluefruit.setTxPower(4); // Max TX power
  Bluefruit.setName("CueStick");
  
  bleuart.begin();
  startAdv();

  lastTime = millis();
}

void startAdv(void) {
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.ScanResponse.addName();
  Bluefruit.Advertising.addService(bleuart);

  Bluefruit.Advertising.start(0); // Always advertise
  Serial.println("Advertising as CueStick...");
}

void loop() {
  // Handle BLE connection
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);  // 20ms - 152.5ms
  Bluefruit.Advertising.setFastTimeout(30);

  // Read IMU
  float gx = imu.readFloatGyroX();
  float gy = imu.readFloatGyroY();
  float gz = imu.readFloatGyroZ();

  float ax = imu.readFloatAccelX();
  float ay = imu.readFloatAccelY();
  float az = imu.readFloatAccelZ();

  unsigned long now = millis();
  float dt = (now - lastTime) / 1000.0;
  lastTime = now;

  // Integrate gyro for yaw
  yaw += gz * dt;

  // Compute pitch, roll from accelerometer
  pitch = atan2(-ax, sqrt(ay * ay + az * az)) * 180.0 / PI;
  roll = atan2(ay, az) * 180.0 / PI;

  // Apply complementary filter
  yaw = alpha * (yaw) + (1 - alpha) * yaw;
  pitch = alpha * pitch + (1 - alpha) * pitch;
  roll = alpha * roll + (1 - alpha) * roll;

  // Apply offset
  float yawDisplay = yaw - yawOffset;
  if (yawDisplay > 180) yawDisplay -= 360;
  if (yawDisplay < -180) yawDisplay += 360;

  // Send BLE data
  static unsigned long lastSend = 0;
  if (millis() - lastSend > 100) {
    char msg[32];
    snprintf(msg, sizeof(msg), "%.2f,%.2f\n", yawDisplay, pitch);
    bleuart.print(msg);
  }

  // Check BLE commands
  if (bleuart.available()) {
    char c = bleuart.read();
    if (c == 'R' || c == 'r') {
      yawOffset = yaw;
      bleuart.println("RESET_OK");
      Serial.println("Yaw reset!");
    }
  }

  delay(50);
}
