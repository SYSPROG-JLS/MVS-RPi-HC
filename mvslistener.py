# 
# This file is part of the MVS-RPi-HC repo.
# Copyright (c) 2021 James Salvino.
# 
# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

#
# Purpose:
#
# This socket program will listen for data
# sent from MVS3.8J using the Hercules 1403 
# printer 01E which MVS uses as a non-JES2 printer.
#
# Data sent from MVS MUST have a blank as the 
# first character sent (1403 cc character).
#
# Depending on the message text that is sent,
# an LED attached to one of the RPi GPIO pins
# will be turned on or off.
#

import socket
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)

#setup the pin on the RPi that the LED is connected to
LED_pin_num = 5
GPIO.setup(LED_pin_num,GPIO.OUT)

#initially turn the LED off
GPIO.output(LED_pin_num, False)

s = socket.socket()

host = '127.0.0.1' #needs to be in quotes
port = 1403

#connect to Hercules 1403 printer 01E
s.connect((host, port))

#this loop will continuously look for data coming from 01E
while True:
    #wait for some data from 01E
    msgbytes = s.recv(1024)

    msg_len = len(msgbytes)

    if msg_len == 0:      #empty? yes, then exit loop
        break
    elif msg_len == 1:    #ignore newline and carriage return characters 
        continue

    #convert bytes variable to string
    msgstring = str(msgbytes).lstrip("b' ").rstrip("'")

    print('Received:', msgstring)

    #turn the LED on or off depending on the message sent from MVS
    if msgstring == 'TURN LED ON':
        GPIO.output(LED_pin_num, True)
    elif msgstring == 'TURN LED OFF':
        GPIO.output(LED_pin_num, False)

#close the socket
s.close()

#perform GPIO cleanup
GPIO.cleanup()

exit()
