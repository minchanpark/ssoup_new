import 'dart:async';
import 'dart:convert';
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
  LatLng? _currentPosition; // nullable로 설정
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

  // 목적지 초기화
  void _initializeDestination() {
    _destinationLocation = LatLng(widget.location[0], widget.location[1]);
  }

  // 권한 확인 및 현재 위치 설정
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
      _getNaverRoute(); // 위치가 설정된 후에 경로를 가져옴
    });

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateCurrentLocationMarker();
        _getNaverRoute(); // 위치 변경 시마다 경로를 다시 가져옴
      });
    });
  }

  // 현재 위치 마커 업데이트
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

  // 목적지 마커 추가
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

  // 경로 데이터를 이용해 폴리라인을 지도에 추가
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

  // Naver API를 사용하여 현재 위치에서 목적지로 경로 가져옴
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

  // Google Map 스타일 설정
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator()) // 초기화되지 않았을 때 로딩 인디케이터
          : GoogleMap(
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
      bottomSheet: ElevatedButton(
        onPressed: () {
          Navigator.push(
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
              side: const BorderSide(width: 1, color: Color(0xFF4FA2FF)),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        child: SizedBox(
          width: 180,
          height: 30,
          child: Center(
            child: Text(
              '안내종료',
              style: medium13.copyWith(
                color: const Color(0xFFFFFFFF),
                fontSize: 15,
                fontFamily: 'S-Core Dream',
                fontWeight: FontWeight.w600,
                height: 0.09,
                letterSpacing: -0.32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
