import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:latlong/latlong.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String barcode = "";
  String qrcodefind;
  List<String> latlng;
  double lat;
  double long;
  Marker mark = new Marker(
    width: 10.0,
    height: 10.0,
    point: new LatLng(43.411223,5.371936),
    builder: (ctx) =>
    new Container(
      child: new Icon(Icons.location_on),
    ),
  );

  List<Marker> markers = [
    new Marker(
      width: 10,
      height: 10,
      point: new LatLng(43.454323,5.470684),
      builder: (ctx) =>
      new Container(
        child: new Icon(Icons.location_on,color: Colors.redAccent),
      ),
    ),
  ];

  updateMarker() {
    setState(() {
      markers.add(mark);
    });
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Barcode Scanner Example'),
          ),
          body: Container(
            child: new FlutterMap(
              options: new MapOptions(
                center: new LatLng(43.454323, 5.470684),
                zoom: 10,
              ),
              layers: [
                new TileLayerOptions(
                  urlTemplate: "https://maps.noan.io/styles/osm-vector/{z}/{x}/{y}.png",
                ),
                new MarkerLayerOptions(
                  markers:  markers,
                ),
              ],
            ),

          ),
          floatingActionButton: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            children: [
              SpeedDialChild(
                child: Icon(Icons.camera_alt),
                label: "scan",
                onTap: scan,
              ),
              SpeedDialChild(
                child: Icon(Icons.add),
                label: "Add Marker",
                onTap: updateMarker,
              ),
              SpeedDialChild(
                label: qrcodefind,
              ),
            ]
          ),
        )
    );
  }

  Future scan() async {
    try {
      String qrcode = await BarcodeScanner.scan();
      setState(() {
        qrcodefind = qrcode;
        barcode = qrcode.replaceAll("GEO:", "");
        latlng = barcode.split(",");
        lat = latlng.elementAt(0) as double;
        long = latlng.elementAt(1) as double;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => barcode =
      'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => barcode = 'Unknown error: $e');
    }
  }
}