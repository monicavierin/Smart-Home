------------------------------------------------------------------------------------------------
# Proyek-Akhir-SSF (Smart Home)

Kelompok 11:
- Monica Vierin Pasman - 2206029405
- Louis Benedict Archie - 2206025224
- Reiki Putra Dermawan - 2206062882
- Adhelia Putri Maylani - 2206814816

------------------------------------------------------------------------------------------------
## Introduction
Traditional home lighting and cooling systems often require manual intervention to turn on or off. This not only demands continuous attention from the occupants but also can lead to inefficient energy usage. For instance, lights may remain on in well-lit conditions, or fans may continue running even when the temperature has dropped, resulting in unnecessary energy consumption and higher utility bills. Specifically, in many homes:
- Lights are left on during daylight hours or when there is sufficient ambient light.
- Cooling devices like fans run continuously, regardless of the actual temperature, leading to energy wastage.

To address these inefficiencies, we propose a smart automation system that can:
- Automatically turn on an LED light when the surrounding light intensity falls below a certain threshold.
- Automatically turn on a fan when the ambient temperature rises above a predefined level.
## Description
Smart Home system provides the ability to automatically turn on an LED light when the surrounding light intensity falls below a certain threshold and Automatically turn on a fan when the ambient temperature rises above a predefined level. The system uses DHT-11 to measure temperature and humidity which will trigger the fan based on the parameter that were set in the system. And using the LCD, the system will display the temperature and the humidity values.

## Hardware and Implementation
In this project, we are using:
- Arduino Uno ATMEGA328p (2)
- Sensor DHT11 (1)
- Sensor LDR (1)
- LED (1)
- LCD (1)
- Motor DC (1)
- Resistor 1k (1)
- Resistor 10k (2)
- Resistor 220 (1)
- Breadboard (2)

Here are the explanation about the hardware that were used and also its implementation:
### 1. Arduino UNO
The Arduino UNO is a popular microcontroller board based on the ATmega328P. The Arduino UNO serves as the central control unit. It receives input signals from the photoresistor and DHT11 sensor, processes these signals, and controls the LED light and fan accordingly

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/6769a09a-6577-40c1-bf72-3a8d88b3a785)

### 2. LCD
A Liquid Crystal Display (LCD) is an electronic display module that uses the light-modulating properties of liquid crystals.In the context of the Smart Home project, an LCD can be used to display real-time data and status updates from the system and providing valuable information at a glance.

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/93472587-40d2-403c-8ffc-482407b673cc)

### 3. DHT11
The DHT11 is a basic, low-cost digital temperature and humidity sensor. It uses a capacitive humidity sensor and a thermistor to measure the surrounding air and provides a digital signal output on the data pin. Based on the temperature readings, the system can automatically control a fan to maintain a comfortable environment.

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/c8bbc0b7-3bce-4653-a522-6b20b3c9a1a2)

### 4. LDR Sensor
A Light Dependent Resistor (LDR), also known as a photoresistor, is an electronic component that varies its resistance based on the intensity of light falling on its surface. The LDR sensor is used to monitor the ambient light level. The system uses this information to automatically control the LED lighting, ensuring that lights are turned on when it is dark and turned off when there is sufficient natural light.

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/e43aebd0-db46-46d0-a720-8e88fbd380fc)

### 5. Motor DC
A Direct Current (DC) motor is an electric motor that runs on direct current (DC) electricity.  a DC motor can be used to drive a fan that provides ventilation based on ambient temperature.

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/2132d954-272e-4684-8e1e-2c40303459ae)

### 6. Breadboard
A breadboard is a rectangular plastic board with a grid of tiny holes that are used to build and test electronic circuits without soldering. A breadboard can be used to prototype and test the various components and their connections.

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/d7fc9423-527e-4e80-89ba-e26e4b5f5ab7)

### 7. Resistor
A resistor is a passive electrical component that implements electrical resistance as a circuit element. It is used to limit the flow of electric current, adjust signal levels, divide voltages, bias active elements, and terminate transmission lines, among other uses. 

![image](https://github.com/monicavierin/Smart-Home/assets/144347093/fa300d4e-48fb-4b46-8b2b-48b32f20be84)

## Software Implemantation
Based on the code, when the room temperature is above the parameters that have been set on DHT11, the system will turn on the fan and when the room is below the temperature of the parameters that have been set, it will turn off the fan. This also applies to lights which will turn on when the light intensity in the room is below the parameter and turn off when the light intensity in the room is below the parameter. Both the data from the DHT11 and LDR Sensor will be displayed in a serial monitor in which the first data is the temperature and the second data is the light intensity. 

## Test Results and Performance Evaluation
