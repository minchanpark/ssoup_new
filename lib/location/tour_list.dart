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
            fontSize: screenWidth * 0.05, // Relative font size
          ),
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TourDetailPage(
                            tourId: tour.id,
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
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.06,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffB7CFFF)),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.025),
                        child: Row(
                          children: [
                            Image.network(
                              tour.image,
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tour.locationName,
                                    style: medium15.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth * 0.038,
                                      letterSpacing: -0.32,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.006),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/system-uicons_location.svg',
                                        width: screenWidth * 0.045,
                                        height: screenWidth * 0.045,
                                        color: const Color(0xff000000),
                                      ),
                                      SizedBox(width: screenWidth * 0.008),
                                      Expanded(
                                        child: Text(
                                          tour.address,
                                          style: light11.copyWith(
                                            fontSize: screenWidth * 0.028,
                                            fontWeight: FontWeight.w300,
                                            height: 1.1,
                                            letterSpacing: -0.32,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.006),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/ph_star.svg',
                                        width: screenWidth * 0.045,
                                        height: screenWidth * 0.045,
                                        color: const Color(0xff000000),
                                      ),
                                      SizedBox(width: screenWidth * 0.008),
                                      FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('locationMap')
                                            .doc(tour.id)
                                            .collection('visitor')
                                            .get(),
                                        builder: (context, snapshot) {
                                          int reviewCount =
                                              snapshot.data?.size ?? 0;
                                          return Text(
                                            "리뷰 $reviewCount개",
                                            style: light11.copyWith(
                                              fontSize: screenWidth * 0.028,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
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
  final String id;
  final String image;
  final List location;
  final String address;
  final String locationName;
  final String duration;

  TourList({
    required this.id,
    required this.image,
    required this.location,
    required this.locationName,
    required this.address,
    required this.duration,
  });
}
