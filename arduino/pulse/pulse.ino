/*
This code is derived from the code provided by the creators of the Pulse Sensor Amped, Joel Murphy and Yury Gitman
https://github.com/WorldFamousElectronics/PulseSensor-Amped/tree/master/PulseSensorAmped%20Arduino%20UNO
(The code included here may include their comments as well.)

This code detects heartbeats and writes a line of text to the serial port to indicate each beat.
*/

//Constants (pins)
#define pulse_pin 0 // Pulse sensor signal wire is connected to analog pin 0.
#define blink_pin 13 // Pin blinks on-board LED to indicate a heartbeat.

// Volatile variables used by interrupts.
volatile int signal;                       // Holds raw input data.
volatile int ibi = 600;                    // Interval between beats.
volatile boolean pulse = false;            // True when wave is high, false when low.
volatile unsigned long last_beat_time = 0; // Used to calculate the interval values contained in 'ibi'
volatile int p = 512;                      // Peak signal value of the pulse wave.
volatile int t = 512;                      // Trough signal value of the pulse wave.
volatile int thresh = 512; // 
volatile int amp = 100;
volatile boolean first_beat = true;

void interruptSetup(){     
  // Initializes Timer2 to throw an interrupt every 2mS.
  TCCR2A = 0x02;     // DISABLE PWM ON DIGITAL PINS 3 AND 11, AND GO INTO CTC MODE
  TCCR2B = 0x06;     // DON'T FORCE COMPARE, 256 PRESCALER 
  OCR2A = 0X7C;      // SET THE TOP OF THE COUNT TO 124 FOR 500Hz SAMPLE RATE
  TIMSK2 = 0x02;     // ENABLE INTERRUPT ON MATCH BETWEEN TIMER2 AND OCR2A
  sei();             // MAKE SURE GLOBAL INTERRUPTS ARE ENABLED
}

ISR(TIMER2_COMPA_vect){
  cli(); // Diable interrupts.
  
  signal = analogRead(pulse_pin);
  int n = millis() - last_beat_time;
  
  // Record data pertaining to the current heartbeat.
  if (signal < thresh && signal > (ibi/5)*3 && signal < t) {
    t = signal;
  } else if (signal > thresh && signal > p) {
    p = signal;
  }
  if (n > 2500) {
    // There has been 2.5 seconds since the last beat, reset.
    thresh = 512;
    p = 512;
    t = 512;
    last_beat_time = millis();
    first_beat = true;
  }
  else if (n > 250) {
    // 250 is a resonable interval requirement to prevent noise.
    if (signal > thresh && pulse == false) {
      pulse = true;
      Serial.println("beat");
      digitalWrite(blink_pin, HIGH);
      ibi = n;
      last_beat_time = millis();
      
      //First beat is unreliable, discard it.
      if (first_beat) {
        first_beat = false;
        sei();
        return;
      } 
    }
  }
  
  if (signal < thresh && pulse == true) {
    // Heartbeat is over, record its data.
    digitalWrite(blink_pin, LOW);
    pulse = false;
    amp = p - t;
    thresh = amp/2 + t;
    p = thresh;
    t = thresh;
  }
    
  sei(); // Re-enable interrupts.
}

void setup(){
  pinMode(blink_pin, OUTPUT);
  Serial.begin(115200);
  last_beat_time = millis();
  interruptSetup();
}

void loop(){}
