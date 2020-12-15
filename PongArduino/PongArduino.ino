#include <SparkFunLSM6DS3.h>
#include <Wire.h>

uint8_t i2CAddressMotor = 0x30;

LSM6DS3 myIMU(I2C_MODE, 0x6A); 

String hapticData;
String hapticPos; // representing the position of the ball in terms of direction
int hapticDistance; // representing the position of the ball in terms of distance

void setup() {
  Serial.begin(115200); // check the Serial Monitor's baud rate
  myIMU.begin();
  enableDriver();
  controlMotor(0, 0, 0, 0);
}

void loop() {
  
  if (Serial.available()) { 
    hapticData = Serial.readStringUntil('\n'); 
  }
  splitHapticData();
  
  vibrate(hapticPos, hapticDistance);
  // hapticData = ""; // TODO: interrupt?
  
  sendIMUData();
  delay(500);
}

/* send IMU data over serial port */
void sendIMUData() {
  Serial.print(myIMU.readFloatGyroX(), 3); // rotation X-axis - roll
  Serial.print(",");
  Serial.print(myIMU.readFloatGyroY(), 3); // rotation Y-axis - pitch
  // Serial.print(",");
  // Serial.print(myIMU.readFloatGyroZ(), 0); // rotation Z-axis - yaw
  Serial.print(",");
  
  Serial.print(myIMU.readFloatAccelX(), 3);
  Serial.print(",");
  Serial.print(myIMU.readFloatAccelY(), 3);
  // Serial.print(",");
  // Serial.print(imu.readFloatAccelZ(), 0);
  Serial.println();
}

/* split haptic data received from Processing */
void splitHapticData() {
  int commaIndex = hapticData.indexOf(',');
  hapticPos = hapticData.substring(0, commaIndex);
  hapticDistance = hapticData.substring(commaIndex + 1).toInt();
}

/* control motors to send vibrotactile feedback */
void vibrate(String id, int dis) { 
  
  if (dis == 0) { //collision
    changeDelay(500);
    controlMotor(1023, 1023, 1023, 1023);
    id = "";
  } else if (dis > 0 && dis <= 5) {
    changeDelay(500);
  } else if (dis > 5 && dis <= 10) {
    changeDelay(1000);
  } else if (dis > 10) {
    changeDelay(2000);
  }
  
  if (id == '1') { // 90 degree above
    controlMotor(555, 555, 0, 0);
  }
  else if (id == '2') { // 90 degree below   
    controlMotor(0, 0, 555, 555);   
  }
  else if (id == '3') { // 90 degree left    
    controlMotor(555, 0, 0, 555);   
  }
  else if (id == '4') { // 90 degree right  
    controlMotor(0, 555, 555, 0);          
  }
  else if (id == '5') { // 45 degree up-left  
    controlMotor(1023, 0, 0, 0);        
  }
  else if (id == '6') { // 45 degree up-right  
    controlMotor(0, 1023, 0, 0);           
  }
  else if (id == '7') { // 45 degree down-left    
    controlMotor(0, 0, 0, 1023);        
  }
  else if (id == '8') { // 45 degree down-right   
    controlMotor(0, 0, 1023, 0);        
  }
  
  delay(10);
} 

/* sending PWM signals to 4 motors */
void controlMotor(int16_t m1_pwm, int16_t m2_pwm, int16_t m3_pwm, int16_t m4_pwm) { //0->1023
  i2cWrite2bytes(i2CAddressMotor, 0x10, m1_pwm);
  i2cWrite2bytes(i2CAddressMotor, 0x11, m2_pwm);
  i2cWrite2bytes(i2CAddressMotor, 0x12, m3_pwm);
  i2cWrite2bytes(i2CAddressMotor, 0x13, m4_pwm);
}

/* change delay time */
void changeDelay(int16_t delayTime) { //default: 200(ms)
  i2cWrite2bytes(i2CAddressMotor, 0x20, delayTime);
}

void enableDriver() {
  i2cWrite(i2CAddressMotor, 0x40);
}

void deactivateDriver() {
  i2cWrite(i2CAddressMotor, 0x41);
}

void i2cWrite2bytes(uint8_t address,uint8_t channel, uint16_t data) { 
  Wire.beginTransmission(address); 
  Wire.write(channel);
  Wire.write(data>>8);
  Wire.write(data);
  Wire.endTransmission();
  delay(15);
}

void i2cWrite(uint8_t address,uint8_t channel) { 
  Wire.beginTransmission(address); 
  Wire.write(channel);
  Wire.endTransmission();
  delay(15);
}
