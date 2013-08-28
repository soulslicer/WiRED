# WiRED

This is the device that me and my coursemate Fawazz built over the summer of 2013. Basically, WiRED and the WiRED Server+App is a full-fledge hardware-app device, that allows one to control any IR device, remotely via an iOS app and the WiRED hardware, from anywhere in the world.

This is made possible by doing a server implementation as well. Hence, WiRED communicates directly with the WiRED server written in java, and the WiRED Server provides API calls for the WiRED iOS App to interact with. The entire source code for this project can be found here in this repo.

![ScreenShot](https://github.com/soulslicer/WiRED/blob/master/Docs/72506_576760025707671_1606132807_n.jpg?raw=true)

### Features
1. Easily deployable server. Is a single .jar file that can run anywhere. Provides full fledge NoSQL Database, multi-threaded TCP listener, and HTTP Servlet listener.
2. Server provides many features, such as push requests to send out IR signals at certain times, or as a group. This is implemented in the app too.
3. Supports a whole plethora of IR protocols, as this uses the IRRemote library found in Arduino
4. Fine tune the number of times your signal repeats for any command/device
5. Full fledge remote control UI interface that is easy to use
6. Easy one-touch set-up to connect WiRED to your home Wi-Fi network. The iOS app guides you through the entire process with visuals.
7. Fully designed original app logo's/images.

### Hardware Needed

![ScreenShot](https://github.com/soulslicer/WiRED/blob/master/Docs/Screen%20Shot%202013-08-27%20at%2010.27.03%20PM.png?raw=true)

1. Breadboard or Solder+Circuit board
2. Arduino Nano
3. RN-XV WiFly Device
4. 2 LEDS
4. 7805 set-up with a clean 5V source
5. Sparkfun Explorer breakout+Sparkfun explorer USB
6. 10k resistor, LEDS and 220 ohm resistors
7. Wires and wire stripper
8. IR LEDS, Buttons, 2N2222 BJT, TSOP4838 IR Receiver

### Software Needed

1. ArduinoCore Library (Provided)
2. Atmel Studio Windows (C++ and Atmega328P)
3. Mac OSX, Xcode and iPhone (If you want to use another platform, read below)
4. CoolTerm for Windows
5. FTDI USB Driver for OSX/Windows


## Setting Up Software/Hardware

Follow the circuit diagrams to build the connections. Then run the WiRED Server by running "java -jar WiREDServer.jar". Take note of your machine's IP. Fire up the device and the app, and push the red button to go into one-touch set-up mode. Simply follow the app's instructions!

## Notes

* iOS App written in Objective-C
* Server written in Java in Eclipse
* Arduino programmed in C++ via Atmel Studio
* ArduinoCore packaged by me, contains all required drivers. Using Arduino Libraries

