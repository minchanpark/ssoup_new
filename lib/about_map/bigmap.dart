import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ssoup_new/constants.dart';
import 'package:ssoup_new/theme/color.dart';
import 'package:ssoup_new/theme/text.dart';
import 'package:url_launcher/url_launcher.dart';

class BigMapPage extends StatefulWidget {
  const BigMapPage({super.key});

  @override
  State<BigMapPage> createState() => _BigMapPageState();
}

class _BigMapPageState extends State<BigMapPage> {
  final LatLng _ulleungDo = const LatLng(37.49893355978079, 130.86866855621338);
  final Set<Marker> _currentMarkers = {};
  final Set<Marker> _touristMarkers = {};
  final Set<Marker> _trashMarkers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _getLocationsFromFB();
    _getTrashLocationsFromFB();
    _determinePosition().then((position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _addCurrentLocationMarker();
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _addCurrentLocationMarker() {
    if (_currentLocation == null) return;

    final Marker currentLocationMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: _currentLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: 'Current Location'),
    );
    setState(() {
      _currentMarkers.add(currentLocationMarker);
    });
  }

  Future<void> _getLocationsFromFB() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('locationMap').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final LatLng location = LatLng(data['location'][0], data['location'][1]);
      final String name = data['locationName'];
      final String information = data['information'];
      final String time = data['time'];
      final String phoneNumber = data['phoneNumber'];
      final String adultPrice = data['adultPrice'];
      final String teenPrice = data['teenPrice'];
      final String kidPrice = data['kidPrice'];
      final String address = data['address'];
      final String imageUrl = data['imageUrl'];

      final Marker touristMarker = Marker(
        markerId: MarkerId(doc.id),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          _showMarkerInfoDialog(name, time, phoneNumber, adultPrice, teenPrice,
              kidPrice, address, information, imageUrl, location);
        },
      );
      setState(() {
        _touristMarkers.add(touristMarker);
        _currentMarkers.add(touristMarker);
      });
    }
  }

  Future<void> _getTrashLocationsFromFB() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('trashMap').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final LatLng location = LatLng(data['location'][0], data['location'][1]);

      final Marker trashMarker = Marker(
        markerId: MarkerId(doc.id),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Trash Bin'),
        onTap: () {
          _getNaverRoute(location);
        },
      );
      setState(() {
        _trashMarkers.add(trashMarker);
        _currentMarkers.add(trashMarker);
      });
    }
  }

  Future<void> _getNaverRoute(LatLng destination) async {
    if (_currentLocation == null) return;

    final url =
        'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=${_currentLocation!.longitude},${_currentLocation!.latitude}&goal=${destination.longitude},${destination.latitude}&option=trafast';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': naverClientId,
        'X-NCP-APIGW-API-KEY': naverClientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic>? routes =
          data['route']?['trafast'] ?? data['route']?['traoptimal'];

      if (routes != null && routes.isNotEmpty) {
        final points = routes[0]['path'];
        _setPolylineFromNaverPoints(points);
      } else {
        print('No routes found');
      }
    } else {
      print('Failed to load directions: ${response.statusCode}');
    }
  }

  void _setPolylineFromNaverPoints(List points) {
    final polylineCoordinates = points.map<LatLng>((point) {
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

  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  void _showMarkerInfoDialog(
    String name,
    String time,
    String phoneNumber,
    String adultPrice,
    String teenPrice,
    String kidPrice,
    String address,
    String information,
    String imageUrl,
    LatLng location,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: (34 / 393) * screenWidth,
                          color: const Color(0xFFD9D9D9),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Text(
                    name,
                    style: medium20.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: (20 / 393) * screenWidth),
                  ),
                  Text(
                    address,
                    style: regular10.copyWith(
                      color: const Color(0xFF909090),
                      fontSize: (14 / 393) * screenWidth,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  SizedBox(height: (18 / 852) * screenHeight),
                  GestureDetector(
                    onTap: () {
                      _makePhoneCall(phoneNumber);
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/phone.svg',
                          width: (14 / 393) * screenWidth,
                          height: (14 / 852) * screenHeight,
                        ),
                        SizedBox(width: (12 / 393) * screenWidth),
                        Text(
                          phoneNumber,
                          style: medium15.copyWith(
                            fontSize: (14 / 393) * screenWidth,
                            color: const Color(0xFF131313),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/clock.svg',
                        alignment: AlignmentDirectional.topStart,
                        width: (14 / 393) * screenWidth,
                        height: (14 / 852) * screenHeight,
                      ),
                      SizedBox(width: (12 / 393) * screenWidth),
                      Text(
                        time,
                        style: medium13.copyWith(
                          color: const Color(0xFF131313),
                          fontSize: (14 / 393) * screenWidth,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          SvgPicture.asset(
                            'assets/won.svg',
                            width: (14 / 393) * screenWidth,
                            height: (14 / 852) * screenHeight,
                          ),
                        ],
                      ),
                      SizedBox(width: (12 / 393) * screenWidth),
                      Column(
                        children: [
                          Text(
                            '어른:     $adultPrice',
                            style: medium13.copyWith(
                              fontSize: (14 / 393) * screenWidth,
                            ),
                          ),
                          Text(
                            '청소년:  $teenPrice',
                            style: medium13.copyWith(
                              fontSize: (14 / 393) * screenWidth,
                            ),
                          ),
                          Text(
                            '아동:     $kidPrice',
                            style: medium13.copyWith(
                              fontSize: (14 / 393) * screenWidth,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: (17 / 852) * screenHeight),
                  const Divider(
                    color: Color(0xffADAAAA),
                    thickness: 1,
                  ),
                  SizedBox(height: (17 / 852) * screenHeight),
                  SizedBox(
                    height: screenHeight * 0.25,
                    child: SingleChildScrollView(
                      child: Text(
                        information,
                        style: medium13.copyWith(
                          color: const Color(0xFF131313),
                          fontSize: (14 / 393) * screenWidth,
                          letterSpacing: -0.28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: (160 / 393) * screenWidth,
                top: (135 / 852) * screenHeight,
                child: Container(
                  width: (90 / 393) * screenWidth, // 원하는 비율로 너비 설정
                  height: (90 / 393) * screenWidth, // 높이를 동일하게 설정하여 원형 유지
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // 원형으로 설정
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover, // 원형에 맞게 이미지 커버
                    ),
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getNaverRoute(location);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF4FA2FF),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFF4FA2FF)),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.05,
                child: Center(
                  child: Text(
                    '안내받기',
                    style: medium13.copyWith(
                      color: Colors.white,
                      fontSize: (15 / 393) * screenWidth,
                      fontFamily: 'S-Core Dream',
                      fontWeight: FontWeight.w600,
                      height: 0.09,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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

  void _filterMarkers(String filter) {
    setState(() {
      _selectedFilter = filter;
      _currentMarkers.clear();
      if (filter == 'all') {
        _currentMarkers.addAll(_touristMarkers);
        _currentMarkers.addAll(_trashMarkers);
      } else if (filter == 'tourist') {
        _currentMarkers.addAll(_touristMarkers);
      } else if (filter == 'trash') {
        _currentMarkers.addAll(_trashMarkers);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            '울릉투어 맵',
            style: regular23.copyWith(
              fontWeight: FontWeight.w500,
              height: 0.03,
              letterSpacing: -0.32,
              fontSize: (23 / 393) * screenWidth,
            ),
          ),
        ),
        backgroundColor: const Color(0xffC6EBFE),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xffC6EBFE),
            child: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.025),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChoiceChip('전체지도', 'all', screenWidth),
                  _buildChoiceChip('관광지', 'tourist', screenWidth),
                  _buildChoiceChip('쓰레기통', 'trash', screenWidth),
                ],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _ulleungDo,
                zoom: 11.8,
              ),
              markers: _currentMarkers,
              onMapCreated: (GoogleMapController controller) {
                _setMapStyle(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String filter, double screenWidth) {
    return ChoiceChip(
      label: Text(
        label,
        style: regular15.copyWith(fontSize: (15 / 393) * screenWidth),
      ),
      selected: _selectedFilter == filter,
      onSelected: (bool selected) {
        _filterMarkers(filter);
      },
      selectedColor: AppColor.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Color(0xffC6EBFE)),
      ),
    );
  }
}
