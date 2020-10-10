import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
  //runApp(SimpleTimeSeriesChart.withSampleData());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Jed\'s IOT Core HW'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;
  void _incrementCounter() {
    setState(() {
      //_counter++;
    });
  }

  Future<bool> sendCommand() async {
    final response = await http.get(
        'https://us-west2-specialtopics-290508.cloudfunctions.net/force_iot_publish_now');

    int statusCode = response.statusCode;
    if (statusCode == 200) {
      print("Command sent!");
      return true;
    } else {
      print("Command NOT sent!");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Homework Options',
            ),
            RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SimpleTimeSeriesChart()),
                  );
                },
                child: Text('Show History')),
            RaisedButton(
              onPressed: () {
                return FutureBuilder(
                  initialData: null,
                  future: sendCommand(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Text content = Text("Command NOT sent!");
                      if (snapshot.data == true) {
                        content = Text("Command sent successfully!");
                      }
                      final snackBar = SnackBar(
                        content: content,
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            // Some code to undo the change.
                          },
                        ),
                      );

                      // Find the Scaffold in the widget tree and use
                      // it to show a SnackBar.
                      Scaffold.of(context).showSnackBar(snackBar);
                      return Scaffold();
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                );
              },
              child: Text('Send Command'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList = [];
  final bool animate = false;
  final firestoreInstance = Firestore.instance;

  //SimpleTimeSeriesChart(this.seriesList, {this.animate});
  SimpleTimeSeriesChart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sensors History"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 400,
              width: 400,
              child: FutureBuilder(
                initialData: null,
                future: getAllData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<TimeSeriesTemp> data = snapshot.data;
                    var seriesList = [
                      new charts.Series<TimeSeriesTemp, DateTime>(
                        id: 'Temperature',
                        colorFn: (_, __) =>
                            charts.MaterialPalette.blue.shadeDefault,
                        domainFn: (TimeSeriesTemp temp, _) => temp.time,
                        measureFn: (TimeSeriesTemp temp, _) => temp.temp,
                        data: data,
                      ),
                      new charts.Series<TimeSeriesTemp, DateTime>(
                        id: 'Humidity',
                        colorFn: (_, __) =>
                            charts.MaterialPalette.green.shadeDefault,
                        domainFn: (TimeSeriesTemp temp, _) => temp.time,
                        measureFn: (TimeSeriesTemp temp, _) => temp.humidity,
                        data: data,
                      )
                    ];
                    return new charts.TimeSeriesChart(
                      seriesList,
                      animate: animate,
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                      domainAxis: charts.DateTimeAxisSpec(
                        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                          day: charts.TimeFormatterSpec(
                            format: 'dd',
                            transitionFormat: 'dd MMM',
                          ),
                        ),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            RaisedButton(
              onPressed: () {
                _onPressed(context);
              },
              child: Text("Live Update"),
            ),
          ],
        ),
      ),
    );
  }

  void _onPressed(context) {
    firestoreInstance.collection("rpi4_sensors").snapshots().listen((result) {
      result.documents.forEach((result) {
        print(result.data);
        (context as Element).reassemble();
        //SimpleTimeSeriesChart();
      });
    });
  }

  static Future<List<TimeSeriesTemp>> getAllData() async {
    final response = await http.get(
        'https://us-west2-specialtopics-290508.cloudfunctions.net/get_all_documents');

    var json = jsonDecode(response.body);
    List<FirestoreData> list = json
        .map<FirestoreData>((json) => FirestoreData.fromJson(json))
        .toList();
    print("List length: ${list.length}");

    List<TimeSeriesTemp> data = [];
    for (var i = 0; i < list.length; i++) {
      var ts = list[i].timestamp;
      var temp = list[i].temperature;
      var hum = list[i].humidity;
      var date = new DateTime.fromMillisecondsSinceEpoch(ts);

      print("${i}, ${date}, ${temp}, ${hum}");

      data.add(TimeSeriesTemp(date, temp, hum));
    }
    return data;
  }
}

/// Sample time series data type.
class TimeSeriesTemp {
  final DateTime time;
  final int temp;
  final int humidity;

  TimeSeriesTemp(this.time, this.temp, this.humidity);
}

class FirestoreData {
  int timestamp;
  int temperature;
  int humidity;

  FirestoreData({this.timestamp, this.temperature, this.humidity});

  factory FirestoreData.fromJson(Map<String, dynamic> json) {
    return FirestoreData(
        timestamp: json["timestamp"],
        temperature: json["temperature"],
        humidity: json["humidity"]);
  }
}
