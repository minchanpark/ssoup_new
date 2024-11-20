import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ssoup_new/constants.dart';

import '../location/review_create_page_tour.dart';
import '../theme/text.dart';

class GoogleMapTourPage extends StatefulWidget {
  final String courseId;
  final List location;

  const GoogleMapTourPage({
    super.key,
    required this.courseId,
    required this.location,
  });

  @override
  _GoogleMapTourPageState createState() => _GoogleMapTourPageState();
}

class _GoogleMapTourPageState extends State<GoogleMapTourPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  late LatLng _destinationLocation;
  final Set<Polyline> _polylines = {};
  StreamSubscription<Position>? _positionStreamSubscription;
  bool dialogShown = false;

  @override
  void initState() {
    super.initState();
    _initializeDestination();
    _checkPermissions();
    _addDestinationMarker();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _initializeDestination() {
    _destinationLocation = LatLng(widget.location[0], widget.location[1]);
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
    }

    final currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      _updateCurrentLocationMarker();
      _getNaverRoute();
    });

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateCurrentLocationMarker();
        _getNaverRoute();
      });
    });
  }

  void _updateCurrentLocationMarker() {
    if (_currentPosition == null) return;

    setState(() {
      _markers.removeWhere((marker) => marker.markerId == const MarkerId('cL'));
      _markers.add(
        Marker(
          markerId: const MarkerId('cL'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    });
  }

  void _addDestinationMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('dL'),
          position: _destinationLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: '목적지'),
        ),
      );
    });
  }

  void _setPolylineFromNaverPoints(List points) {
    final List<LatLng> polylineCoordinates = points.map<LatLng>((point) {
      return LatLng(point[1], point[0]);
    }).toList();

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  Future<void> _getNaverRoute() async {
    if (_currentPosition == null) return;

    final url =
        'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=${_currentPosition!.longitude},${_currentPosition!.latitude}&goal=${_destinationLocation.longitude},${_destinationLocation.latitude}&option=trafast';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': naverClientId,
        'X-NCP-APIGW-API-KEY': naverClientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['route']?['trafast']?.first['path'] ?? [];

      if (points.isNotEmpty) {
        _setPolylineFromNaverPoints(points);
      }
    } else {
      print('Failed to load directions: ${response.statusCode}');
    }
  }

  void _setMapStyle(GoogleMapController controller) async {
    const style = '''[
    {
      "featureType": "all",
      "elementType": "labels",
      "stylers": [
        { "visibility": "on" }
      ]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [
        { "color": "#ffffff" }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        { "color": "#C6EBFE" }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        { "visibility": "simplified" },
        { "color": "#cccccc" }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [
        { "color": "#ffffff" }
      ]
    }
  ]''';
    controller.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    User? user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: _currentPosition == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show a loading indicator if position is null
          : Stack(
              children: [
                // Use Positioned.fill to make the GoogleMap fill the available space
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      _setMapStyle(controller);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    polylines: _polylines,
                  ),
                ),
                // Position the button at the bottom center
                Positioned(
                  bottom: (50 / 852) * screenHeight,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        (uid == null || uid.isEmpty)
                            ? Navigator.of(context).pop()
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewCreatePageTour(
                                    courseId: widget.courseId,
                                  ),
                                ),
                              );
                      },
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(0),
                        backgroundColor: const WidgetStatePropertyAll(
                          Color(0xFF4FA2FF),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFF4FA2FF)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: (180 / 393) * screenWidth,
                        height: (30 / 852) * screenHeight,
                        child: Center(
                          child: Text(
                            '안내종료',
                            style: medium13.copyWith(
                              color: const Color(0xFFFFFFFF),
                              fontSize: (15 / 393) * screenWidth,
                              fontFamily: 'S-Core Dream',
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
