#!/bin/env coffee

express = require 'express'
app = express()
server = (require 'http').Server app
socketio = require 'socket.io'
io = socketio server
SerialPort = (require 'serialport').SerialPort

# Setup static web server and bind to port 8080
app.use (express.static (__dirname + '/../static'))
server.listen 8080

# Serial port setup
serialPort =
  new SerialPort process.argv[process.argv.length - 1], baudrate : 115200, false

serialPort.open (error) ->
  if error
    console.log 'Opening the serial port ' + serialPort.path + ' failed.'
    console.log error
    process.exit 1
  else
    console.log 'Serial port ' + serialPort.path + ' open.'
    serialPort.on 'data', (data) ->
      # On data from Arduino, write to console
      # and direct socket.io to emit a message
      # to all open browsers.

      io.emit ('beat')
      console.log (data.toString 'ascii')

    serialPort.on 'close', () ->
      console.log 'Serial port ' + serialPort.path + ' has closed. Exiting...'
      process.exit 2

    serialPort.on 'error', (error) ->
      console.log error
