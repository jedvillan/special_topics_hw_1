# Special Topics HW 1: Area 1 - IoT and mobile devices with Google Cloud backend (firebase)

### Description
This project demonstrates a simple mobile application communicating with an iot device through the Google Cloud Platform services. The IoT device publishes data and listens for any incoming messages using the MQTT protocol. IoT Core with Pub/Sub handles the communication and Google Functions handles storing the data to Firestore. The mobile app has 3 main functions:
1. Pull the data from Firestore and plot it in a graph
1. Send command to IoT device 
1. Get real-time data and display in the graph as the the IoT device publishes

### Components
1. Android Mobile App (Flutter) [/iotcore_raspberry_sensors]
1. IoT device (Raspberry Pi 4) [/mqtt_raspberry_pi]
1. Google Cloud Backend/Services (Firebase, Firestore, Pub/Sub, Functions, IoT Core) [/functions/save_to_firestore]

