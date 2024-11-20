import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ssoup_new/theme/text.dart';
import '../theme/color.dart';

class PhotoReviewTourPage extends StatefulWidget {
  final String courseId;

  const PhotoReviewTourPage({super.key, required this.courseId});

  @override
  State<PhotoReviewTourPage> createState() => _PhotoReviewTourPageState();
}

class _PhotoReviewTourPageState extends State<PhotoReviewTourPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        title: Text(
          '포토 리뷰 모아보기',
          style: regular15.copyWith(
            fontSize: 18,
            height: 1.16,
            letterSpacing: -0.32,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('locationMap')
            .doc(widget.courseId)
            .collection('visitor')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var visitor = snapshot.data!.docs;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.068,
              vertical: screenHeight * 0.043,
            ),
            child: GridView.builder(
              itemCount: visitor.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 15,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.button),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      visitor[index]['reviewImageUrl'],
                      width: 105,
                      height: 102,
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
