How to control lights and other devices from MVS3.8J running on a Raspberry Pi

Wouldn't it be cool to be able to run a JES2 job on MVS to turn on or off a light
in your house? If you think so, then read on.

The Raspberry Pi (RPi) is a small single-board computer (SBC) developed in the 
United Kingdom by the Raspberry Pi Foundation in association with Broadcom. 

Price is about 35 USD.

It runs a Debian-based (32-bit) Linux. 
Which means it can run Hercules (and MVS3.8J). And runs it quite well I might add!

What makes the Raspberry Pi really useful though is that it sports input/output pins
to which you can connect properly interfaced devices that you want to control such as 
lights, motors, etc. These I/O pins can be accessed and programmed using the Python 
programming language.

---------------------------------------------------------------------

Here is my setup:

A Raspberry Pi 2 Mod B (4× Cortex-A7 900 MHz; 1Gb RAM) running the following software:

1) The Raspbian operating system at this level:

pi@RPi2ModB:/etc $ uname -a
Linux RPi2ModB 5.10.17-v7+ #1421 SMP Thu May 27 13:59:01 BST 2021 armv71 GNU/Linux

pi@RPi2ModB:/etc $ cat os-release
PRETTY_NAME="Raspbian GNU/Linux 10 (buster)"
NAME="Raspbian GNU/Linux"
VERSION_ID="10"
VERSION="10 (buster)"
VERSION_CODENAME=buster
ID=raspbian
ID_LIKE=debian
HOME_URL="http://www.raspbian.org/"
SUPPORT_URL="http://www.raspbian.org/RaspbianForums"
BUG_REPORT_URL="http://www.raspbian.org/RaspbianBugs"

pi@RPi2ModB:/etc $ cat debian_version
10.10

---------------------------------------------------------------------

2) Hercules Version 3.13 - installed using the standard 
Debian apt-get utility.

---------------------------------------------------------------------

3) MVS3.8J - built using Jay Moseley's instructions
(http://www.jaymoseley.com/hercules/installMVS/iMVSintroV7.htm)

Note: TK4 users should have no problems following these instructions.

---------------------------------------------------------------------

Requirements:

1) This project makes use of the sockdev argument on a Hercules 1403 line printer device

Place the following device statement in your MVS config file:

001E    1403    localhost:1403 sockdev

01E needs to be included in the IOGEN of your MVS system AND it MUST NOT be defined to JES2.


2) Download Python program 'mvslistener.py' from this repo and put it in /home/pi on 
your Raspberry Pi. This is a simple Python socket program that listens on port 1403 for 
data sent to it from Hercules/MVS. It will take certain actions based on the data 
received (like bringing RPi I/O pins high or low). 


3) To demonstrate proper operation we need to hook up a logic probe
to GPIO5 (RPi pin 29). The ground wire on the logic probe is attached to 
GND (RPi pin 39).

Note: if you don't have access to a logic probe (or an analog multimeter set to the 5VDC scale),
you can use an LED and a 470 ohm resistor hooked up as follows:

                470 ohm resistor
GPIO5 pin 29 ____/\/\/\___
                          |
                          |led anode
                        ----  
                        |  | 
                        ---- 
                          |led cathode
GND   pin 39 _____________|


Either of these will simulate a light in your house that you want to
control.

---------------------------------------------------------------------

Procedure:

1) Boot up the Raspberry Pi

2) Start Hercules

3) IPL MVS

4) In another terminal window start mvslistener.py by typing:
python3 mvslistener.py

5) At this point the LED should not be lit (OFF).

6) Download from the repo and submit to JES job INIT1403.JCL
This ASMCG job will satisfy a mount request for a 1403 UCS
printer chain. After this MVS will no longer ask, so
let's get it out of the way right now. 

Over on the terminal where mvslistener.py is running you 
should see the following message displayed: 'Received: INIT 1403'.

Here is a sample of the MVS console log for this job:
Note the Operator reply that must be given to mount the UCS 'AN' chain

0200 07.15.58 JOB  136  $HASP100 INIT1403 ON READER1     INIT 1403
4000 07.15.58 JOB  136  $HASP373 INIT1403 STARTED - INIT  1 - CLASS A - SYS HMVS
4000 07.15.58 JOB  136  IEF403I INIT1403 - STARTED - TIME=07.15.58
4000 07.16.00 JOB  136  IEFACTRT ASM     /IFOX00  /00:00:01.58/00:00:02.13/00000/INIT1403
4200 07.16.01 JOB  136  IEF236I ALLOC. FOR INIT1403 GO INIT
4200 07.16.01 JOB  136  IEF237I 01E  ALLOCATED TO OUTFLE
0200 07.16.01 JOB  136 *02 IEC120A M 01E,AN
0200 07.16.32           IEE600I REPLY TO 02 IS;'AN'
0000 07.16.32           R 02,'AN'
4000 07.16.32 JOB  136  IEFACTRT GO      /LOADER  /00:00:00.17/00:00:31.58/00000/INIT1403
4000 07.16.32 JOB  136  $HASP395 INIT1403 ENDED
C000 07.16.32           $HASP309    INIT  1 INACTIVE ******** C=A
0200 07.16.32 JOB  136  $HASP150 INIT1403 ON PUNCH1           9 CARDS
0200 07.16.32 JOB  136 *$HASP190 INIT1403 SETUP -- PUNCH1   -- F = STD1
0200 07.16.32 JOB  136  $HASP150 INIT1403 ON PRINTER1       239 LINES
0200 07.16.32           $HASP160 PRINTER1 INACTIVE - CLASS=A
4000 07.16.32 JOB  136  IEF404I INIT1403 - ENDED - TIME=07.16.32
0000 07.18.50           $S PUN1
0200 07.18.50           $HASP160 PUNCH1   INACTIVE - CLASS=B
0200 07.18.50 JOB  136  $HASP250 INIT1403 IS PURGED
0000 07.18.50           $HASP000 OK

7) Download from the repo and submit to JES job TOGGLELED.JCL
This ASMCG job will assemble a simple program that will OPEN the 
01E printer, PUT a message to turn ON the LED, sleep for 5
seconds, then PUT a message to turn OFF the LED, and finally CLOSE
the 01E printer and END. 

While this job is running you should see your
LED turn ON for 5 seconds then turn OFF.

Over on the terminal where mvslistener.py is running you 
should see the following messages displayed:
Received: TURN LED ON
Received: TURN LED OFF

Here is a sample of the MVS console log for this job:

0200 07.35.09 JOB  137  $HASP100 TOGGLEL  ON READER1     TOGGLE LED
4000 07.35.09 JOB  137  $HASP373 TOGGLEL  STARTED - INIT  1 - CLASS A - SYS HMVS
4000 07.35.09 JOB  137  IEF403I TOGGLEL - STARTED - TIME=07.35.09
4000 07.35.11 JOB  137  IEFACTRT ASM     /IFOX00  /00:00:01.42/00:00:01.86/00000/TOGGLEL
4200 07.35.11 JOB  137  IEF236I ALLOC. FOR TOGGLEL GO INIT
4200 07.35.11 JOB  137  IEF237I 01E  ALLOCATED TO OUTFLE
4000 07.35.16 JOB  137  IEFACTRT GO      /LOADER  /00:00:00.24/00:00:05.30/00000/TOGGLEL
4000 07.35.16 JOB  137  $HASP395 TOGGLEL  ENDED
C000 07.35.17           $HASP309    INIT  1 INACTIVE ******** C=A
0200 07.35.17 JOB  137  $HASP150 TOGGLEL  ON PRINTER1       271 LINES
0200 07.35.17 JOB  137  $HASP150 TOGGLEL  ON PUNCH1          11 CARDS
0200 07.35.17           $HASP160 PUNCH1   INACTIVE - CLASS=B
0200 07.35.17           $HASP160 PRINTER1 INACTIVE - CLASS=A
0200 07.35.17 JOB  137  $HASP250 TOGGLEL  IS PURGED
4000 07.35.16 JOB  137  IEF404I TOGGLEL - ENDED - TIME=07.35.16


So that's it. I hope you try this out. 
And feel free to contact me with questions.