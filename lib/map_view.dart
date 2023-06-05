// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late LatLng _latLng;

  void _onMapTap(LatLng latLng) {
    setState(() {
      _latLng = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 12.0,
        ),
        onTap: _onMapTap,
        markers: _latLng != null
            ? {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _latLng,
                ),
              }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          Navigator.of(context).pop(_latLng);
        },
      ),
    );
  }
}
