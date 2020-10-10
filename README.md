# Special Topics HW 1: Area 1 - IoT and Mobile Devices with Google Cloud Backend (Firebase)

### Description
This project demonstrates a simple mobile application communicating with an iot device through the Google Cloud Platform services. The IoT device publishes data and listens for any incoming messages using the MQTT protocol. IoT Core with Pub/Sub handles the communication and Google Functions handles storing the data to Firestore. The mobile app has 3 main functions:
1. Pull the data from Firestore and plot it in a graph
1. Send command to IoT device 
1. Get real-time data and display in the graph as the the IoT device publishes

### Components
1. Android Mobile App (Flutter) [/iotcore_raspberry_sensors]
1. IoT device (Raspberry Pi 4) [/mqtt_raspberry_pi]
1. Google Cloud Backend/Services (Firebase, Firestore, Pub/Sub, Functions, IoT Core) [/functions/save_to_firestore]

### Steps to Completion
1. Create a mobile app - I used Flutter with Microsoft Visual Studio Code and Android Studio for the emulator
1. Create a Firebase project
1. In the project, register the app (get applicationId from app build.gradle)
1. Start a Firestore collection
1. Create a Pub/Sub topic
1. Register IoT device to IoT Core
1. Start a Google Functions project - I used NodeJS to write my functions
  * Functions necessary
    1. save_data_to_firestore - Subscribed to PubSub to listen for new messages from IoT device. When a new message arrives, this will save the data to Firestore.
    1. get_all_documents - The mobile app will make an HTTP request to this function to get all the documents from the Firestore collection where the data is stored.
    1. force_iot_publish_now - The mobile app will make an HTTP request to this function to force the IoT device publish data immediately instead of waiting for the 10 seconds interval it is set to do.
1. 
1. 
