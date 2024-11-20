import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'plogging_detail.dart';
import '../theme/text.dart';

class PloggingPage extends StatefulWidget {
  const PloggingPage({super.key});

  @override
  _PloggingPageState createState() => _PloggingPageState();
}

class _PloggingPageState extends State<PloggingPage> {
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
          '플로깅 장소',
          style: medium20.copyWith(
            color: const Color(0xff484646),
            fontSize: screenWidth * 0.05, // Relative font size
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('course').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var courses = snapshot.data!.docs.map((doc) {
            return Course(
              id: doc.id,
              image: doc['courseImageUrl'],
              title: doc['courseName'],
              startLocation: doc['startLocation'],
              endLocation: doc['endLocation'],
              locationName: doc['startLocationName'],
              duration: '${doc['spendTime']}',
            );
          }).toList();

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(
                            courseId: course.id,
                            courseImage: course.image,
                            courseTitle: course.title,
                            courseLocationName: course.locationName,
                            courseStartLocation: course.startLocation,
                            courseEndLocation: course.endLocation,
                            courseDuration: course.duration,
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
                              course.image,
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
                                    course.title,
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
                                      ),
                                      SizedBox(width: screenWidth * 0.008),
                                      Expanded(
                                        child: Text(
                                          course.locationName,
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
                                      ),
                                      SizedBox(width: screenWidth * 0.008),
                                      FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('course')
                                            .doc(course.id)
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

class Course {
  final String id;
  final String image;
  final String title;
  final List startLocation;
  final List endLocation;
  final String locationName;
  final String duration;

  Course({
    required this.id,
    required this.image,
    required this.title,
    required this.startLocation,
    required this.endLocation,
    required this.duration,
    required this.locationName,
  });
}
