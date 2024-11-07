import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ssoup_new/plogging/photo_review.dart';
import '../theme/color.dart';
import '../theme/text.dart';

class CourseReviewPage extends StatefulWidget {
  final String courseId;
  final String courseImage;
  final String courseTitle;

  final String courseLocationName;
  const CourseReviewPage(
      {super.key,
      required this.courseId,
      required this.courseImage,
      required this.courseTitle,
      required this.courseLocationName});

  @override
  State<CourseReviewPage> createState() => _CourseReviewPageState();
}

class _CourseReviewPageState extends State<CourseReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String nickname = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchNickname();
  }

  Future<void> _fetchNickname() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot documentSnapshot =
            await _firestore.collection('user').doc(user.uid).get();

        setState(() {
          nickname = documentSnapshot['nick_name'];
        });
      } catch (e) {
        print("Error fetching nickname: $e");
      }
    } else {
      print("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double averageScore(List<DocumentSnapshot> visitor) {
      if (visitor.isEmpty) return 0.0;
      double total = 0.0;
      for (var review in visitor) {
        total += review['score'];
      }
      return total / visitor.length;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * (22 / 852)),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('course')
                .doc(widget.courseId)
                .collection('visitor')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              var visitor = snapshot.data!.docs;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color: index < averageScore(visitor).round()
                                ? AppColor.button
                                : Colors.grey,
                            size: 35,
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * (21 / 393)),
                      Row(
                        children: [
                          Text(
                            averageScore(visitor).toStringAsFixed(1),
                            style: medium20.copyWith(),
                          ),
                          Text(
                            '/5 ',
                            style: medium20.copyWith(
                                color: const Color.fromRGBO(173, 170, 170, 1)),
                          ),
                          Text(
                            '(${visitor.length})',
                            style: regular13.copyWith(
                                color: const Color.fromRGBO(173, 170, 170, 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * (18 / 852)),
                  const Divider(
                    color: Color(0xffF3F3F3),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * (25 / 393),
                        bottom: screenHeight * (18 / 852),
                        top: screenHeight * (18 / 852)),
                    child: Row(
                      children: [
                        const Text(
                          "리뷰",
                          style: medium20,
                        ),
                        Text(
                          " ${visitor.length}",
                          style: medium20.copyWith(
                            color: const Color(0xffadaaaa),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(178, 178, 178, 0.4),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * (25 / 393),
                        right: screenWidth * (25 / 393)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (visitor.isNotEmpty &&
                                visitor[0]['reviewImageUrl'] == null)
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: AppColor.button,
                                ),
                              )
                            : (visitor.isNotEmpty)
                                ? Container(
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColor.button),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        visitor[0]['reviewImageUrl'],
                                        width: 105,
                                        height: 102,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )
                                : Container(),
                        (visitor.length > 1 &&
                                visitor[1]['reviewImageUrl'] == null)
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: AppColor.button,
                                ),
                              )
                            : (visitor.length > 1)
                                ? Container(
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColor.button),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        visitor[1]['reviewImageUrl'],
                                        width: 105,
                                        height: 102,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )
                                : Container(),
                        (visitor.length > 2 &&
                                visitor[2]['reviewImageUrl'] == null)
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: AppColor.button,
                                ),
                              )
                            : (visitor.length > 2)
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PhotoReviewPage(
                                                    courseId: widget.courseId,
                                                  )));
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColor.button),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              visitor[2]['reviewImageUrl'],
                                              width: 105,
                                              height: 102,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 105,
                                          height: 102,
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.5),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        Positioned(
                                          left: 22,
                                          top: 40,
                                          child: Text(
                                            '+ 더보기',
                                            style: medium15.copyWith(
                                              color: const Color(0xffffffff),
                                              fontSize:
                                                  screenWidth * (15 / 393),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(178, 178, 178, 0.4),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visitor.length,
                    itemBuilder: (context, index) {
                      var review = visitor[index];
                      return Padding(
                        padding:
                            EdgeInsets.only(left: screenWidth * (25 / 393)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                review['reviewImageUrl'] != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColor.button),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            review['reviewImageUrl'],
                                            width: 105,
                                            height: 102,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: screenWidth * (105 / 393),
                                        height: screenHeight * (102 / 852),
                                      ),
                                SizedBox(width: screenWidth * (12 / 393)),
                                // Spacing between image and text
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '이름',
                                            style: medium15.copyWith(
                                                color: const Color(0xff7A7A7A)),
                                          ),
                                          SizedBox(
                                              height:
                                                  screenHeight * (12 / 852)),
                                          Text(
                                            '장소',
                                            style: medium15.copyWith(
                                                color: const Color(0xff7A7A7A)),
                                          ),
                                          SizedBox(
                                              height:
                                                  screenHeight * (12 / 852)),
                                          Text(
                                            '별점',
                                            style: medium15.copyWith(
                                                color: const Color(0xff7A7A7A)),
                                          ),
                                        ]),
                                    SizedBox(
                                      width: screenWidth * (21 / 393),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${review['username']}',
                                          style: medium15,
                                        ),
                                        SizedBox(
                                            height: screenHeight * (12 / 852)),
                                        Text(
                                          widget.courseTitle,
                                          style: medium15,
                                        ),
                                        SizedBox(
                                            height: screenHeight * (12 / 852)),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (starIndex) => Icon(
                                              Icons.star,
                                              color: starIndex <
                                                      review['score'].toInt()
                                                  ? AppColor.button
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenHeight * (23 / 852),
                                bottom: screenHeight * (14 / 852),
                                right: screenWidth * (25 / 393),
                              ),
                              child: Text(
                                review['review'],
                                style: regular15,
                              ),
                            ),
                            const Divider(
                              color: Color.fromRGBO(178, 178, 178, 0.4),
                              endIndent: 30,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
