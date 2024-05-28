------------------------------------------------------------------------------------------------
# Proyek-Akhir-SSF (Smart Home)

Kelompok 11:
- Monica Vierin Pasman - 2206029405
- Louis Benedict Archie - 2206025224
- Reiki Putra Dermawan - 2206062882
- Adhelia Putri Maylani - 2206814816

------------------------------------------------------------------------------------------------
## Introduction to the problem and the solution
Traditional home lighting and cooling systems often require manual intervention to turn on or off. This not only demands continuous attention from the occupants but also can lead to inefficient energy usage. For instance, lights may remain on in well-lit conditions, or fans may continue running even when the temperature has dropped, resulting in unnecessary energy consumption and higher utility bills. Specifically, in many homes:
- Lights are left on during daylight hours or when there is sufficient ambient light.
- Cooling devices like fans run continuously, regardless of the actual temperature, leading to energy wastage.

To address these inefficiencies, we propose a smart automation system that can:
- Automatically turn on an LED light when the surrounding light intensity falls below a certain threshold.
- Automatically turn on a fan when the ambient temperature rises above a predefined level.
## Description
Smart Home system provides the ability to automatically turn on an LED light when the surrounding light intensity falls below a certain threshold and Automatically turn on a fan when the ambient temperature rises above a predefined level. The system uses DHT-11 to measure temperature and humidity which will trigger the fan based on the parameter that were set in the system. 

## Hardware and Implementation
In this project, we are using:
- Arduino Uno ATMEGA328p (2)
- Sensor DHT11 (1)
- Sensor LDR (1)
- LED (1)
- Motor DC (1)
- Resistor 1k (1)
- Resistor 10k (2)
- Resistor 220 (1)
- Breadboard (2)

Here are the explanation about the hardware that were used and also its implementation:
### 1. Arduino UNO
The Arduino UNO is a popular microcontroller board based on the ATmega328P. The Arduino UNO serves as the central control unit. It receives input signals from the photoresistor and DHT11 sensor, processes these signals, and controls the LED light and fan accordingly

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/6769a09a-6577-40c1-bf72-3a8d88b3a785)

### 2. DHT11
The DHT11 is a basic, low-cost digital temperature and humidity sensor. It uses a capacitive humidity sensor and a thermistor to measure the surrounding air and provides a digital signal output on the data pin. This sensor is connected to the Arduino master, which will read temperature and humidity data from this sensor. Based on the data obtained, the Arduino master will send this information to the Arduino slave to control the DC motor.

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/c8bbc0b7-3bce-4653-a522-6b20b3c9a1a2)

### 3. LDR Sensor
A Light Dependent Resistor (LDR), also known as a photoresistor, is an electronic component that varies its resistance based on the intensity of light falling on its surface. The LDR sensor is used to monitor the ambient light level. This sensor is also connected to the Arduino master. The Arduino master will read the resistance of the LDR which has been determined depending on the light intensity. Information is then sent to the Arduino slave to control the LED light based on day (low resistance) or night (high resistance) conditions.

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/e43aebd0-db46-46d0-a720-8e88fbd380fc)

### 4. Motor DC
A Direct Current (DC) motor is an electric motor that runs on direct current (DC) electricity.  a DC motor can be used to drive a fan that provides ventilation based on ambient temperature. A DC motor is used to drive the fan in this system. The Arduino slave will control the DC motor to turn the fan on or off

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/2132d954-272e-4684-8e1e-2c40303459ae)

### 5. Breadboard
A breadboard is a rectangular plastic board with a grid of tiny holes that are used to build and test electronic circuits without soldering. A breadboard can be used to prototype and test the various components and their connections.

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/d7fc9423-527e-4e80-89ba-e26e4b5f5ab7)

### 6. Resistor
A resistor is a passive electrical component that implements electrical resistance as a circuit element. It is used to limit the flow of electric current, adjust signal levels, divide voltages, bias active elements, and terminate transmission lines, among other uses. 

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/fa300d4e-48fb-4b46-8b2b-48b32f20be84)

## Software Implemantation
Based on the code, when the room temperature is above the parameters that have been set on DHT11, the system will turn on the fan and when the room is below the temperature of the parameters that have been set, it will turn off the fan. This also applies to lights which will turn on when the light intensity in the room is below the parameter and turn off when the light intensity in the room is below the parameter. Both the data from the DHT11 and LDR Sensor will be displayed in a serial monitor in which the first data is the temperature and the second data is the light intensity. 

## Test Results and Performance Evaluation
### 1. Test Results
Here are the test results for this project:

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/c85e79a2-9c02-45c3-bb3e-a1ef00c863f6)

Based on the test results obtained from Proteus, we can conclude that the system we created has worked according to the criteria. That is, when the light intensity in the room is lower than the parameters that have been set, the lights will be turned off and when the light intensity is higher than the parameters that have been set on the sensor, the lights will turn off automatically as seen in the picture, the LED lights up because of the intensity of the light. too low. And also when the temperature in the room exceeds the parameters set on the sensor it will activate the motor so the fan turns on and when the temperature in the room no longer exceeds the parameters set on the sensor it will turn off the motor so the fan turns off automatically as in the picture, namely when If the temperature is too high, it will activate the motor, where the motor is a fan which will lower the temperature in the room.

### 2. Performance Evaluation
Even though the criteria have been achieved, there are several obstacles and problems that exist when creating and running this project. Evaluation of this project is that our system cannot use LCD because when using LCD, the fan and LED in the system will not turn on and when the fan and LED are on, the LCD used will not turn on. So we decided not to use an LCD which reduces the function of the system that has been created. We suspect that this problem arises due to programming errors on the Arduino master and Arduino slave.

## Conclusion and Future Work
### 1. Conclusion
The Smart Home system that we have created meets the criteria and expectations that we have set. This system can provide assistance in maintaining room temperature and also indoor lighting. Not only that, this system can also indirectly save energy because it does the work automatically so there is no waste of energy due to the use of inefficient tools.

The conclusion of this project is that the series and results of the tests that have been carried out show that this project has run well because it has met the criteria to be achieved. However, there are still several obstacles that need to be fixed so that we can produce a better and more efficient series than the one we are making now.

### 2. Future Work
For future work, we need to add an LCD to provide information about the temperature and light intensity in the room. Not only that, to further develop this project, we need to add various ways so that this system can be implemented for other tools so that it can help save energy and also make daily activities easier. With this, this system will certainly be very helpful in our daily activities, especially at home and will also save energy because everything is done automatically.
