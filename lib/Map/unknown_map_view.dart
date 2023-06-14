import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
// import 'package:url_launcher/url_launcher.dart';

class UnknownMapView extends StatefulWidget {
  const UnknownMapView({super.key});

  @override
  State<UnknownMapView> createState() => _UnknownMapViewState();
}

class _UnknownMapViewState extends State<UnknownMapView> {
  LatLng _latLng = const LatLng(51.509364, -0.128928);

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
      body: FlutterMap(
        options: MapOptions(
          onTap: (tapPosition, point) => {_onMapTap(point)},
          center: const LatLng(51.509364, -0.128928),
          zoom: 18.0,
        ),
        // nonRotatedChildren: [
        //   RichAttributionWidget(
        //     attributions: [
        //       TextSourceAttribution(
        //         'OpenStreetMap contributors',
        //         onTap: () => launchUrl(
        //             Uri.parse('https://openstreetmap.org/copyright')),
        //       ),
        //     ],
        //   ),
        // ],
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 100.0,
                height: 100.0,
                builder: (context) {
                  return const Icon(
                    size: 50.0,
                    Icons.location_pin,
                    color: Colors.red,
                  );
                },
                point: _latLng,
              )
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop(_latLng);
              },
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

class StartTravel extends StatefulWidget {
  const StartTravel({super.key});

  @override
  State<StartTravel> createState() => _StartTravelState();
}

class _StartTravelState extends State<StartTravel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: FutureBuilder<Position>(
        future: Geolocator.getCurrentPosition(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Position currentPosition = snapshot.data!;
            LatLng startPoint =
                LatLng(currentPosition.latitude, currentPosition.longitude);
            LatLng endPoint = const LatLng(19.0612295, 73.0098839);

            Polyline polyline =
                Polyline(points: [startPoint, endPoint], color: Colors.blue);
            return FlutterMap(
              options: MapOptions(
                center: startPoint,
                zoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: [
                  Marker(
                    width: 100.0,
                    height: 100.0,
                    builder: (context) {
                      return const Icon(
                        size: 50.0,
                        Icons.location_pin,
                        color: Colors.red,
                      );
                    },
                    point: startPoint,
                  ),
                  Marker(
                    width: 100.0,
                    height: 100.0,
                    builder: (context) {
                      return const Icon(
                        size: 50.0,
                        Icons.location_pin,
                        color: Colors.red,
                      );
                    },
                    point: endPoint,
                  ),
                ]),
                PolylineLayer(
                  polylines: [polyline],
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
