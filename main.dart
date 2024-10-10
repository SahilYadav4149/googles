import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'directions_model.dart';
import 'directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _defaultCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  GoogleMapController? _controller;

  double? latitude;
  double? longitude;

  // Initial map position
  LatLng get _initialPosition => LatLng(latitude ?? 21.1702,
      longitude ?? 79.0871); // Default to Nagpur if not set

  final double _geofenceLimit = 500;
  // Move Where_from and Where_to here
  String? whereFrom;
  String? whereTo;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Google Maps'),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('ORIGIN'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('DEST'),
            )
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text(
                'Lat: ${latitude?.toString() ?? 'N/A'}',
                style: const TextStyle(fontSize: 15.0, color: Colors.black),
              ),
              Text(
                '   Long: ${longitude?.toString() ?? 'N/A'}',
                style: const TextStyle(fontSize: 15.0, color: Colors.black),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _controller = controller;
                  _googleMapController =
                      controller; // Assign to the controller variable
                });
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 10,
              ),
              liteModeEnabled: false,
              zoomControlsEnabled: false,
              circles: {
                Circle(
                  circleId: const CircleId('geofence'),
                  center: _initialPosition,
                  radius: _geofenceLimit,
                  fillColor: Colors.blue.withOpacity(0.3),
                  strokeColor: Colors.black,
                  strokeWidth: 2,
                ),
              },
            ),
          ),

          const SizedBox(
            height: 40.0,
          ),
          TextField(
            onChanged: (value) {
              whereFrom = value;
            },
            style: const TextStyle(
                color: Colors.black), // Set the input text color to black
            decoration: const InputDecoration(
              hintText: 'Where From?',
              helperStyle: TextStyle(color: Colors.black),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
          ),

          const SizedBox(
            height: 9.0,
          ),
          // 'Where to?' TextField
          TextField(
            onChanged: (value) {
              setState(() {
                whereTo = value;
              });
            },
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: 'Where To?',
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
    } else {
      // Permissions granted, get the location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(
          'Current Location: Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      // Update the UI with the current location
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    }
  }
}
