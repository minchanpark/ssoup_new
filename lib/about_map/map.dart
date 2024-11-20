//관광지 길 안내를 위한 페이지

import 'dart:async';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ssoup_new/constants.dart';
import 'package:ssoup_new/plogging/review_create_page.dart';
import 'package:ssoup_new/theme/text.dart';

class GoogleMapPage extends StatefulWidget {
  final List startLocation;
  final List endLocation;
  final String courseId;

  const GoogleMapPage({
    super.key,
    required this.startLocation,
    required this.endLocation,
    required this.courseId,
  });

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  final Set<Marker> _markers = {};
  late LatLng _destinationLocation;
  late LatLng _startLocation;
  final Set<Polyline> _polylines = {};
  StreamSubscription<Position>? _positionStreamSubscription;
  bool dialogShown = false;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _checkPermissions();
    _addInitialMarkers();
    _getNaverRoute();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // 위치 초기화
  void _initializeLocations() {
    _startLocation = LatLng(widget.startLocation[0], widget.startLocation[1]);
    _destinationLocation = LatLng(widget.endLocation[0], widget.endLocation[1]);
    _currentPosition = _startLocation;
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
    });

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateCurrentLocationMarker();

        if (_calculateDistance(
                  _currentPosition.latitude,
                  _currentPosition.longitude,
                  _destinationLocation.latitude,
                  _destinationLocation.longitude,
                ) <=
                30 &&
            !dialogShown) {
          _showArrivalPopup(context, _destinationLocation, _startLocation);
          dialogShown = true;
        }
      });
    });
  }

  // 현재 위치 마커 업데이트
  void _updateCurrentLocationMarker() {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == const MarkerId('cL'));
      _markers.add(
        Marker(
          markerId: const MarkerId('cL'),
          position: _currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    });
  }

  // 초기 마커 추가 (출발지 및 도착지)
  void _addInitialMarkers() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('sL'),
          position: _startLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: '여기서 출발하세요!'),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('dL'),
          position: _destinationLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: '여기서 스탬프를 얻을 수 있어요!'),
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

  // 도착지에 도달했을 때 팝업 표시
  Future<void> _showArrivalPopup(
      BuildContext context, LatLng destination, LatLng startLocation) async {
    try {
      final locationSnapshot = await FirebaseFirestore.instance
          .collection('locationMap')
          .where('location', whereIn: [
        [destination.latitude, destination.longitude],
        [startLocation.latitude, startLocation.longitude]
      ]).get();

      if (locationSnapshot.docs.isNotEmpty) {
        for (var locationDoc in locationSnapshot.docs) {
          String stampUid = locationDoc['stampUid'];

          Map<String, dynamic>? stampDetail = await _fetchStampData(stampUid);
          if (stampDetail != null) {
            String userDocId = FirebaseAuth.instance.currentUser?.uid ?? "";
            await FirebaseFirestore.instance
                .collection('user')
                .doc(userDocId)
                .update({
              'stampId': FieldValue.arrayUnion([stampUid]),
            });

            // 스탬프 팝업 표시
            showDialog(
              context: context,
              barrierDismissible: true, // 팝업 외부 클릭 시 닫기 가능
              builder: (BuildContext context) {
                double screenWidth = MediaQuery.of(context).size.width;
                double screenHeight = MediaQuery.of(context).size.height;
                DateTime now = DateTime.now();

                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28), // 다이얼로그 모서리 둥글게 설정
                  ),
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: (332 / 393) * screenWidth,
                      height: (603 / 852) * screenHeight,
                      child: Column(
                        children: <Widget>[
                          // 스탬프 획득 텍스트
                          Padding(
                            padding: EdgeInsets.only(
                              top: (69 / 852) * screenHeight,
                              bottom: (31 / 852) * screenHeight,
                            ),
                            child: Text(
                              '스탬프 획득',
                              style: extrabold24.copyWith(
                                fontFamily: 'S-Core Dream',
                                fontWeight: FontWeight.w700,
                                fontSize: (24 / 393) * screenWidth,
                                height: 0.04,
                                color: const Color(0xFF1E528D),
                              ),
                            ),
                          ),
                          // 두 개의 이미지를 겹치는 Stack
                          Stack(
                            children: <Widget>[
                              // 배경 이미지 (블루 컨테이너)
                              Image.asset(
                                "assets/blue_container.png",
                                width: (282 / 393) * screenWidth,
                                height: (195 / 852) * screenHeight,
                              ),
                              // 스탬프 이미지
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child:
                                    Image.network(stampDetail['stampImageUrl']),
                              ),
                            ],
                          ),
                          SizedBox(height: (15 / 852) * screenHeight), // 간격을 줌
                          // 플로깅 인증 완료 텍스트
                          Text(
                            '${stampDetail['location']} 플로깅 인증 완료!',
                            style: medium16.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: (16 / 393) * screenWidth,
                              letterSpacing: -0.32,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: (18 / 852) * screenHeight),
                          Text(
                            '일시: ${DateFormat('yyyy.MM.dd / kk:mm').format(now)}',
                            style: medium16.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.32,
                              fontSize: (16 / 393) * screenWidth,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: (20 / 852) * screenHeight),
                          Image.asset(
                            "assets/heart.png",
                            width: (282 / 393) * screenWidth,
                            height: (40 / 852) * screenHeight,
                          ),
                          SizedBox(height: (34 / 852) * screenHeight),
                          // 확인 버튼
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 리뷰쓰기 버튼
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xff50A2FF), // 배경색 설정
                                  minimumSize: Size(
                                    (129 / 393) * screenWidth, // 너비
                                    (40.8 / 852) * screenHeight, // 높이
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  dialogShown = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewCreatePage(
                                        courseId: widget.courseId,
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    if (dialogShown == true) {
                                      Navigator.pop(context);
                                    }
                                  });
                                },
                                child: Text(
                                  '리뷰쓰기',
                                  style: bold15.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    height: 0.11,
                                    fontSize: (14 / 393) * screenWidth,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: (6 / 393) * screenWidth), // 버튼 간 간격
                              // 닫기 버튼
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0, // 그림자 없앰
                                  backgroundColor: Colors.white, // 배경색
                                  minimumSize: Size(
                                    (129 / 393) * screenWidth, // 너비
                                    (40.8 / 852) * screenHeight, // 높이
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                      color: Color(0xff4468AD), // 테두리 색
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // 닫기 버튼 클릭 시 팝업 닫기
                                },
                                child: Text(
                                  '닫기',
                                  style: bold15.copyWith(
                                    color: const Color(0xFF4FA2FF),
                                    fontWeight: FontWeight.w600,
                                    height: 0.11,
                                    fontSize: (14 / 393) * screenWidth,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      } else {
        print("No matching location found");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Firebase에서 스탬프 데이터를 가져옴
  Future<Map<String, dynamic>?> _fetchStampData(String stampUid) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('stamp')
        .doc(stampUid)
        .get();
    return snapshot.data() as Map<String, dynamic>?;
  }

  // 두 위치 사이의 거리를 계산
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  // Naver API를 사용하여 초기 경로 가져옴
  Future<void> _getNaverRoute() async {
    final url =
        'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=${_startLocation.longitude},${_startLocation.latitude}&goal=${_destinationLocation.longitude},${_destinationLocation.latitude}&option=trafast';

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
    // ignore: deprecated_member_use
    controller.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _startLocation,
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
    );
  }
}
