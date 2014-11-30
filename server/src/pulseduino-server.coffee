#!/bin/env coffee

express = require 'express'
app = express()
server = (require 'http').Server(app)
SerialPort = (require 'serialport').SerialPort
Server = require 'socket.io'

# Bind port 8080
app.use (express.static (__dirname + '/../static'))

server.listen 8080

# Bind socket.io to server
io = new Server server

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

      io.emit (data.toString 'ascii')
      console.log (data.toString 'ascii')

    serialPort.on 'close', () ->
      console.log 'Serial port ' + serialPort.path + ' has closed. Exiting...'
      process.exit 2

    serialPort.on 'error', (error) ->
      console.log error
