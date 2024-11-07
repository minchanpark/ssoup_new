import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/text.dart';
import 'tour_detail_page.dart';

class TourListPage extends StatefulWidget {
  const TourListPage({super.key});

  @override
  _TourListPageState createState() => _TourListPageState();
}

class _TourListPageState extends State<TourListPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xff484646)),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '관광 명소',
          style: medium20.copyWith(
              color: const Color(0xff484646),
              fontSize: screenWidth * (20 / 393)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('locationMap').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var courses = snapshot.data!.docs.map((doc) {
            return TourList(
              id: doc.id,
              image: doc['imageUrl'],
              location: doc['location'],
              locationName: doc['locationName'],
              address: doc['address'],
              duration: doc['duration'],
            );
          }).toList();

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final tour = courses[index];

              return Column(
                children: [
                  SizedBox(height: screenHeight * (10 / 852)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TourDetailPage(
                            tourId: tour.id, // courseId 전달
                            tourImage: tour.image,
                            tourLocationName: tour.locationName,
                            location: tour.location,
                            duration: tour.duration,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: (13.0 / 852) * screenHeight,
                        horizontal: (25.0 / 393) * screenWidth,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffB7CFFF)),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Image.network(
                              tour.image,
                              width: (78 / 393) * screenWidth,
                              height: 78,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: screenWidth * (9.0 / 393)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tour.locationName,
                                    style: medium15.copyWith(
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.32,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * (5.0 / 852)),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/system-uicons_location.svg',
                                        width: 18,
                                        height: 18,
                                        color: const Color(0xff000000),
                                      ),
                                      SizedBox(width: screenWidth * (3 / 393)),
                                      Expanded(
                                        child: Text(
                                          tour.address,
                                          style: light11.copyWith(
                                            fontSize: (11 / 393) * screenWidth,
                                            fontWeight: FontWeight.w300,
                                            height: 1.1,
                                            letterSpacing: -0.32,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * (5 / 852)),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/ph_star.svg',
                                        width: 18,
                                        height: 18,
                                        color: const Color(0xff000000),
                                      ),
                                      SizedBox(width: screenWidth * (3 / 393)),
                                      FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('locationMap')
                                            .doc(tour.id)
                                            .collection('visitor')
                                            .get(),
                                        builder: (context, snapshot) {
                                          int reviewCount =
                                              snapshot.data?.size ?? 0;
                                          return Text("리뷰 $reviewCount개",
                                              style: light11);
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: screenWidth * (4 / 393)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class TourList {
  final String id; // 코스 ID 추가
  final String image;
  final List location;
  final String address;
  final String locationName;
  final String duration;

  TourList({
    required this.id, // 코스 ID 추가
    required this.image,
    required this.location,
    required this.locationName,
    required this.address,
    required this.duration,
  });
}
