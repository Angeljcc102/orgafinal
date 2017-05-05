void setup() {
  pinMode(0,INPUT);
  pinMode(1,INPUT);  // Inputs
  Serial.begin(9600);  
}

void loop() {
  int leerPuerto0 = analogRead(0);
  int leerPuerto1 = analogRead(1);
  String sendstr=(String)leerPuerto0+"|"+(String)leerPuerto1;
  Serial.println(sendstr);
  delay(50);                      // Alenta las cosas
}
