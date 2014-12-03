/*
  This is a simulation of a correctly working pulse sensor 
  sending a signal over serial. This is used for testing in
  the event a real pulse sensor is unavailable or 
  malfunctioning.
  
  This is not meant to be an accurate simulation of a human
  heart rate, it simply writes to the serial connection roughly
  every one second.
*/

void setup(){
  Serial.begin(115200);
}

void loop(){
  Serial.print("beat");
  delay(1000);
}
  
  
