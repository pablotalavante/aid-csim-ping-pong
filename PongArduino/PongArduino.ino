#include <SparkFunLSM6DS3.h>
#include <Wire.h>

LSM6DS3 myIMU(I2C_MODE, 0x6A); 

//the id representing the position of the ball, received from Processing
char hapticId; 

void setup() {
  Serial.begin(115200); // check the Serial Montor's baud rate
  myIMU.begin();
}

void loop() {
  
  Serial.print(myIMU.readFloatGyroX(), 0); //rotation X-axis - roll
  Serial.print(",");
  Serial.print(myIMU.readFloatGyroY(), 0); //rotation Y-axis - pitch
  //Serial.print(",");
  //Serial.print(myIMU.readFloatGyroZ(), 0); //rotation Z-axis - yaw
  Serial.print(",");
  
  Serial.print(myIMU.readFloatAccelX(), 0);
  Serial.print(",");
  Serial.print(myIMU.readFloatAccelY(), 0);
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

//control motors to send vibrotactile feedback
void vibrate(int id) { 
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
  else if (id == '5')
  {          
  }
  else if (id == '6')
  {          
  }
  else if (id == '7')
  {          
  }
  else if (id == '8')
  {          
  }
  else if (id == '9')
  {          
  }
  delay(10);*/
}
