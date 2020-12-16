#include <SparkFunLSM6DS3.h>
#include <Wire.h>

uint8_t i2CAddressMotor = 0x30;

LSM6DS3 myIMU(I2C_MODE, 0x6A); 

String hapticData;
float hapticX; 
float hapticY; 

void setup() {
  Serial.begin(115200); // check the Serial Monitor's baud rate
  Wire.begin();
  myIMU.begin();

  delay(500);
  Wire.begin();
  enableDriver();
  controlMotor(0, 0, 0, 0);
}

void loop() {

  ledMOn();
  ledMOff();
  
  if (Serial.available()) { 
    hapticData = Serial.readStringUntil('\n'); 
  }
  splitHapticData();
  
  vibrate(100, 100);
  //vibrate(hapticX, hapticY);
  // TODO: interrupt?
  
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
  hapticX = hapticData.substring(0, commaIndex).toFloat();
  hapticY = hapticData.substring(commaIndex + 1).toFloat();
}

/* control motors to send vibrotactile feedback */
void vibrate(float x, float y) { 
  int16_t pwm1 = 0;
  int16_t pwm2 = 0;
  int16_t pwm3 = 0;
  int16_t pwm4 = 0;
  
  x = constrain(x, -500, 500);
  y = constrain(y, -500, 500);
   
  if (x < 0) {
  // M2 
  pwm2 = (int16_t) map(x, 0, 500, 255, 0);   
  } else {
  // M4  
  pwm4 = (int16_t) map(x, 0, 500, 255, 0);  
  }

  if ( y < 0) {
  // M3  
  pwm3 = (int16_t) map(x, 0, 500, 255, 0); 
  } else {
  // M1  
  pwm1 = (int16_t) map(x, 0, 500, 255, 0); 
  }
  
  controlMotor(pwm1, pwm2, pwm3, pwm4);
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

void ledMOn() {
  i2cWrite(i2CAddressMotor, 0x01);
}

void ledMOff() {
  i2cWrite(i2CAddressMotor, 0x02);
}

void i2cWrite2bytes(uint8_t address,uint8_t channel, uint16_t data) { 
  Wire.beginTransmission(address); 
  Wire.write(channel);
  Wire.write(data>>8); // TODO: check both direction
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
