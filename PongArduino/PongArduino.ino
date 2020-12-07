#include <SparkFunLSM6DS3.h>
#include <Wire.h>

LSM6DS3 imu(I2C_MODE, 0x6A); 

//the id representing the position of the ball, received from Processing 
//can be "1","2", etc. or "UPPER_LEFT", "LOWER_RIGHT", etc. -> to be discussed
char hapticId; 

void setup() {
  Serial.begin(115200); 
  imu.begin();
}

void loop() {
  Serial.print(imu.readFloatGyroX(), 0); //rotation X-axis - roll
  Serial.print(",");
  Serial.print(imu.readFloatGyroY(), 0); //rotation Y-axis - pitch
  //Serial.print(",");
  //Serial.print(imu.readFloatGyroZ(), 0); //rotation Z-axis - yaw
  Serial.print(",");
  Serial.print(imu.readFloatAccelX(), 0);
  Serial.print(",");
  Serial.print(imu.readFloatAccelY(), 0);
  //Serial.print(",");
  //Serial.print(imu.readFloatAccelZ(), 0);
  Serial.println();

  if (Serial.available()) 
  { 
    hapticId = Serial.read(); 
  }
  vibrate(hapticId);
  hapticId = '0'; //TODO: need or no need?
  
  delay(500);
}

void vibrate(int id) {
  //control motors to send vibrotactile feedback here
  /*if (id == '1') 
  {
  }
  else if (id == '2')
  {        
  }
  else if (id == '3')
  {        
  }
  else if (id == '4')
  {          
  }
  delay(10);*/
}
