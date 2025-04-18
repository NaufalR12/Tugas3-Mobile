import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class TrackingPage extends StatefulWidget {
  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? _mapController;
  Location _location = Location();
  bool _tracking = false;
  Marker? _currentLocationMarker;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  void _checkLocationPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }
  }

  void _startTracking() {
    _tracking = true;
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (_mapController != null && _tracking) {
        LatLng latLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));

        setState(() {
          _currentLocationMarker = Marker(
            markerId: MarkerId('current_location'),
            position: latLng,
            infoWindow: InfoWindow(title: 'Lokasi Anda'),
          );
        });
      }
    });
    setState(() {});
  }

  void _stopTracking() {
    _tracking = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking LBS'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(-6.200000, 106.816666), // Jakarta default
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _currentLocationMarker != null ? {_currentLocationMarker!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Text(
                _tracking ? 'Tracking: Aktif' : 'Tracking: Nonaktif',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tracking ? _stopTracking() : _startTracking();
        },
        child: Icon(_tracking ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
