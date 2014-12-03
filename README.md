Pulseduino
==========

Snake-like game that ticks in rhythm with the player's heartbeat.

## Introduction

[Video](http://youtu.be/b1KI0D4YoWw)

### Prerequisites

Software:
* Arduino programming software
* Node.js 

Hardware:
* Arduino Uno, Arduino Pro, Arduino Pro Mini
    * Other Arduinos may be compatible, but those will require modifications to the `.ino` source files. See 'Setup' below.
* [Pulse Sensor Amped](https://pulsesensor.myshopify.com/)

## Setup

To run locally:

1. Clone repo.
2. Load `arduino/pulse.ino` onto an Arduino. The `interruptSetup()` varibles are registers and their assigned values will work only on ATMega328 and 16Mhz Arduino hardware, such as the Arduino Uno. For more information, look [here](https://pulsesensor.myshopify.com/pages/pulse-sensor-amped-arduino-v1dot1).
3. Run `npm install` inside of the `server/` directory.
4. Connect the Arduino if you haven't already and search for the serial device on your system. On OS X, this can be done with `ls /dev/tty.usb*`, for other systems you should Google it.
5. Run `coffeescript server/src/pulseduino-server.coffee [serialDeviceFile]`.
6. Put on the pulse sensor, the output of the above command, should output `beat` for each heatbeat if working correctly.
7. If everything is working, go to `http://localhost:8080/snake.html` in your choice of web browser.
8. Play?

## Troubleshooting

Unfortunately, I cannot get the Pulse Sensor Amped to work consistently. If that is not correctly detecting heartbeats, you can always load `arduino/pulse-sim.ino` onto your Arduino. It 'simulates' a heartbeat by writing a string of 'beat' over the serial connection every 1000 milliseconds. I used this to test the serial and websocket components.
