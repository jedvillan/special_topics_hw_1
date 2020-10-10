const functions = require('firebase-functions');
const admin = require('firebase-admin');

const iot = require('@google-cloud/iot');


admin.initializeApp();

exports.save_data_to_firestore = functions
  .region('us-west2')
  .pubsub.topic('rasppi4-cpu-temp')
  .onPublish((message, context) => {
    const messageBody = message.data ? Buffer.from(message.data, 'base64').toString() : null;
    data = JSON.parse(messageBody);
    ts = data["ts"];
    temp = data["temperature"];
    humidity = data["humidity"];

	to_save = {
		timestamp: ts,
		temperature: temp,
		humidity: humidity
	};

	const writeResult = admin.firestore().collection('rpi4_sensors').add(to_save);
	// Send back a message that we've succesfully written the message
	console.log(`Message with ID: ${writeResult.id} added.`);

    console.log(temp);

});

exports.get_all_documents = functions
	.region('us-west2')
	.https.onRequest((req, res) => {
	
	admin
    .firestore()
    .collection('rpi4_sensors')
	.orderBy('timestamp','desc')
	.limit(10)
    .get()
    .then(querySnapshot => {
      const arrSensors = querySnapshot.docs.map(element => element.data());
      return res.send(arrSensors);  //You don't need to use return for an HTTPS Cloud Function
      //res.status(200).send(JSON.stringify(arrSensors));   //Just use response.send()
    }).catch(error => {
      //response.send(error);
      return res.status(500).send(error)   //use status(500) here
    });
	
});

exports.get_last_document = functions
	.region('us-west2')
	.https.onRequest((req, res) => {
	
	admin
    .firestore()
    .collection('rpi4_sensors')
	.orderBy('timestamp','desc')
	.limit(1)
    .get()
    .then(querySnapshot => {
      const arrSensors = querySnapshot.docs.map(element => element.data());
      return res.send(arrSensors);  //You don't need to use return for an HTTPS Cloud Function
      //res.status(200).send(JSON.stringify(arrSensors));   //Just use response.send()
    }).catch(error => {
      //response.send(error);
      return res.status(500).send(error)   //use status(500) here
    });
	
});

exports.force_iot_publish_now = functions
	.region('us-west2')
	.https.onRequest((req, res) => {
		const iotClient = new iot.v1.DeviceManagerClient();
		const cloudRegion = 'us-central1';
		const deviceId = 'raspberry-pi-4';
		const commandMessage = 'Send readings now!';
		const projectId = 'specialtopics-290508';
		const registryId = 'st-iotcore-hw-1';
		
		const formattedName = iotClient.devicePath(
			projectId,
			cloudRegion,
			registryId,
			deviceId
		);
		const binaryData = Buffer.from(commandMessage);
		const request = {
			name: formattedName,
			binaryData: binaryData,
		};
		
		try {
			const responses = iotClient.sendCommandToDevice(request);
			console.log('Sent command: ', responses[0]);
			return res.status(200).send('Command sent!');
		} catch (err) {
			console.error('Could not send command:', err);
			return res.status(500).send('Command not sent!');
		}
});
