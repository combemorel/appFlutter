import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
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
  String text = '';

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

  updateMarker(Marker marker) {
    setState(() {
      markers.add(marker);
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
          floatingActionButton: FloatingActionButton.extended(
              icon: Icon(Icons.camera_alt),
              label: Text("scan"),
              onPressed: scan
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        )
    );
  }

  Future scan() async {
    Marker marker = new Marker(
      width: 10.0,
      height: 10.0,
      point: new LatLng(43.411223,5.371936),
      builder: (ctx) =>
      new Container(
        child: new Icon(Icons.location_on),
      ),
    );
    try {
      String qrcode = await BarcodeScanner.scan();
      setState(() {
        text = qrcode as String;
        String barcode = qrcode.replaceAll("GEO:", "");
        List<String> latlng = barcode.split(",");
        double lat = latlng.elementAt(0) as double;
        double long = latlng.elementAt(1) as double;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          text = 'Utilisation de la camera non permisse';
        });
      } else {
        setState(() => text = 'Erreur lors du scan');
      }
    } on FormatException {
      setState(() => text =
      'null (Appuye sur le bouton back avant le scan)');
    } catch (e) {
      setState(() => text = text as String);
    }
    updateMarker(marker);
  }
}