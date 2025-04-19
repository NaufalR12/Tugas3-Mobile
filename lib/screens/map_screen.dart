import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart'; // Untuk Clipboard
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'marker_data.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  List<MarkerData> _markerData = [];
  List<Marker> _markers = [];
  LatLng? _selectedPosition;
  LatLng? _mylocation;
  LatLng? _draggedPosition;
  bool _isDragging = false;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  // get current location
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if(!serviceEnabled){
    return Future.error("Location services are disabled");
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
          return Future.error("Location permissions are denied");
      }
  }

  if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
  }

  return await Geolocator.getCurrentPosition();
}

  // show current location
  void _showCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(currentLatLng, 15.0);
      setState(() {
        _mylocation = currentLatLng;
      });
    } catch (e) {
      print(e);
    }
  }

  // add marker on selected location anywhere you want to
  void addMarker(LatLng position, String title, String description) {
    setState(() {
      final markerData = MarkerData(
          position: position, title: title, description: description);
      _markerData.add(markerData);
      _markers.add(
        Marker(
          point: position,
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(markerData),
            // onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ), 
                    ],
                  ), 
                  child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ), // TextStyle
                ), // Text
                ),
                Icon(
                Icons.location_on,
                color: Colors.redAccent,
                size: 40,
              ),
              ], 
            ), 
          ), 
        ), 
      );
    });
  }

  void _showMarkerDialog(BuildContext context, LatLng position){
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Add Marker"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: descController,
            decoration: InputDecoration(labelText: "Description"),
          ),
        ],
      ),
      actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Cancel"),
      ), 
      TextButton(
      onPressed: () {
        addMarker(position, titleController.text, descController.text);
        Navigator.pop(context);
      },
      child: Text("Save"),
    )
    ],
    ),
  );
  }

  // show marker info when tapped

  // i am creating just simple you can also add more features and make it more functional.
  void _showMarkerInfo(MarkerData markerData) {
    final lat = markerData.position.latitude.toStringAsFixed(6);
    final lon = markerData.position.longitude.toStringAsFixed(6);
    final coords = "$lat, $lon";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(markerData.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(markerData.description),
            SizedBox(height: 10),
            Text("Koordinat:"),
            SelectableText(coords),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: coords));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Koordinat disalin: $coords")),
              );
            },
            icon: Icon(Icons.copy),
            label: Text("Salin Koordinat"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup"),
          ),
        ],
      ),
    );
  }


  // search
    Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final url = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&countrycodes=ID&accept-language=id';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data.isNotEmpty) {
      setState(() {
          _searchResults = data;
      });
  } else {
      setState(() {
          _searchResults = [];
      });
  }
  }

  // move to specific location
  void _moveToLocation(double lat, double lon) {
    LatLng location = LatLng(lat, lon);
    _mapController.move(location, 15.0);

    // Tambahkan marker secara otomatis
    addSimpleMarker(location);

    setState(() {
      _selectedPosition = location;
      _searchResults = [];
      _isSearching = false;
      _searchController.clear();
    });
  }

  // Tambahkan marker tanpa informasi apapun
void addSimpleMarker(LatLng position) {
  setState(() {
    _markers.add(
      Marker(
        point: position,
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            final lat = position.latitude.toStringAsFixed(6);
            final lon = position.longitude.toStringAsFixed(6);
            final coords = "$lat, $lon";
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Koordinat Lokasi"),
                content: SelectableText(coords),
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: coords));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Koordinat disalin: $coords")),
                      );
                    },
                    icon: Icon(Icons.copy),
                    label: Text("Salin"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Tutup"),
                  ),
                ],
              ),
            );
          },
          child: Icon(
            Icons.location_on,
            color: Colors.redAccent,
            size: 40,
          ),
        ),
      ),
    );
  });
}


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _searchPlaces(_searchController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(-7.7769, 110.3572), // Koordinat Babarsari, Sleman, Yogyakarta
              initialZoom: 13.0,
              onTap: (tapPosition, latlng) {
                setState(() {
                  _selectedPosition = latlng;
                  _draggedPosition = _selectedPosition;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(markers: _markers),
              if (_isDragging && _draggedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _draggedPosition!,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.indigo,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              if (_mylocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _mylocation!,
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        final lat = _mylocation!.latitude.toStringAsFixed(6);
                        final lon = _mylocation!.longitude.toStringAsFixed(6);
                        final coords = "$lat, $lon";
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Lokasi Saya"),
                            content: SelectableText(coords),
                            actions: [
                              TextButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: coords));
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Koordinat disalin: $coords")),
                                  );
                                },
                                icon: Icon(Icons.copy),
                                label: Text("Salin"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Tutup"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
          // search widget
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Column(
              children: [
                SizedBox(
                  height: 55,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search place...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ), // OutlineInputBorder
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _isSearching
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _isSearching = false;
                                _searchResults = [];
                              });
                            },
                            icon: Icon(Icons.clear),
                          )
                        : null,
                      ), 
                      onTap: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                  ), 
                ),
                if (_isSearching && _searchResults.isNotEmpty)
                Container(
                  color: Colors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (ctx, index) {
                      final place = _searchResults[index];
                      return ListTile(
                      title: Text(place['display_name'],),
                      onTap: (){
                        final lat = double.parse(place['lat']);
                        final lon = double.parse(place['lon']);
                        _moveToLocation(lat, lon);
                      },
                    ); 
                    },
                  ), 
                ),
              ],
            ),
          ),
          // add location button
        _isDragging == false ? Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            onPressed: (){
              setState(() {
                _isDragging = true;
              });
            },
            child: Icon(Icons.add_location),
          ), // FloatingActionButton
        ) : Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            onPressed: () {
              setState(() {
                _isDragging = false;
              });
            },
            child: Icon(Icons.wrong_location),
          ),
        ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  onPressed: _showCurrentLocation,
                  child: Icon(Icons.location_searching_rounded),
                ), 
                if (_isDragging)
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: FloatingActionButton(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        if (_draggedPosition != null) {
                          // adding marker
                          _showMarkerDialog(context, _draggedPosition!);
                        }
                     setState(() {
                      _isDragging = false;
                      _draggedPosition = null;
                    });
                    },
                    child: Icon(Icons.check),
                    ), // FloatingActionButton
                  ), // Padding
              ],
            ), // Column
          ), // Positioned
        ],
      ),
    );
  }
}