import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/color.dart';
import '../theme/text.dart';
import 'photo_review_tour.dart';

class TourReviewPage extends StatefulWidget {
  final String tourId;
  final String tourImage;
  final String tourTitle;

  const TourReviewPage({
    super.key,
    required this.tourId,
    required this.tourImage,
    required this.tourTitle,
  });

  @override
  State<TourReviewPage> createState() => _TourReviewPageState();
}

class _TourReviewPageState extends State<TourReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자 UID 저장
  String currentUserId = "";

  // 차단된 사용자 목록을 저장할 변수
  List<String> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      _fetchBlockedUsers(); // 차단된 사용자 목록을 가져옵니다.
    } else {
      print("User not logged in");
    }
  }

  // 차단된 사용자 목록을 가져오는 함수
  void _fetchBlockedUsers() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('user').doc(currentUserId).get();
    if (userDoc.exists) {
      setState(() {
        // 'blockedUsers' 필드를 가져와서 리스트로 변환하여 저장
        blockedUsers = List<String>.from(userDoc.get('blockedUsers') ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 가로, 세로 크기를 가져옵니다.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 평균 점수를 계산하는 함수
    double averageScore(List<DocumentSnapshot> visitor) {
      if (visitor.isEmpty) return 0.0;
      double total = 0.0;
      for (var review in visitor) {
        total += review['score'];
      }
      return total / visitor.length;
    }

    /// 사용자를 차단하는 함수
    void blockUser(String blockedUserId) {
      if (currentUserId.isNotEmpty) {
        _firestore.collection('user').doc(currentUserId).update({
          'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
        });
        // 차단된 사용자 목록을 업데이트합니다.
        setState(() {
          blockedUsers.add(blockedUserId);
        });
      } else {
        print("Current user ID is empty");
      }
    }

    /// 사용자를 신고하는 함수 (신고 사유 포함)
    void reportUser(String reportedUserId, String reason) {
      if (currentUserId.isNotEmpty) {
        _firestore.collection('reports').add({
          'reporterId': currentUserId,
          'reportedUserId': reportedUserId,
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print("Current user ID is empty");
      }
    }

    void blockDialog(String targetUid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0), // 여백을 좀 더 넉넉하게 설정
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '해당 사용자를 차단하시겠습니까?\n해당 리뷰가 목록에 노출되지 않고 다시 해제하실 수 없습니다.',
                    style: medium13.copyWith(fontSize: screenWidth * 0.045),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // 다이얼로그 닫기
                        },
                        child: Text(
                          '취소',
                          style: medium15.copyWith(
                              fontSize: screenWidth * 0.04, color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          blockUser(targetUid);
                          Navigator.pop(context); // 다이얼로그 닫기
                        },
                        child: Text(
                          '차단하기',
                          style: medium15.copyWith(
                              fontSize: screenWidth * 0.04,
                              color: AppColor.button),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // 신고 카테고리 메뉴를 표시하는 함수
    void showReportMenu(
        BuildContext context, Offset position, String targetUid) {
      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      double screenWidth = MediaQuery.of(context).size.width;

      showMenu<String>(
        context: context,
        color: Colors.white,
        position: RelativeRect.fromRect(
          position & Size((30 / 393) * screenWidth, 0), // 터치 영역의 위치와 크기
          Offset.zero & overlay.size, // 전체 화면 크기
        ),
        items: <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: '음란물/불건전한 만남 및 대화',
            child: Text(
              '음란물/불건전한 만남 및 대화',
              style: medium13.copyWith(fontSize: screenWidth * 0.033),
            ),
          ),
          PopupMenuItem<String>(
            value: '상업적 광고 및 판매',
            child: Text(
              '상업적 광고 및 판매',
              style: medium13.copyWith(fontSize: screenWidth * 0.033),
            ),
          ),
          PopupMenuItem<String>(
            value: '낚시/놀람',
            child: Text(
              '낚시/놀람',
              style: medium13.copyWith(fontSize: screenWidth * 0.033),
            ),
          ),
          PopupMenuItem<String>(
            value: '리뷰 게시판 성격에 부적절한 내용',
            child: Text(
              '리뷰 게시판 성격에 부적절한 내용',
              style: medium13.copyWith(fontSize: screenWidth * 0.033),
            ),
          ),
          PopupMenuItem<String>(
            value: '욕설/비하',
            child: Text(
              '욕설/비하',
              style: medium13.copyWith(fontSize: screenWidth * 0.033),
            ),
          ),
          // 필요한 신고 항목을 추가하세요
        ],
      ).then((String? value) {
        if (value != null) {
          // 선택된 신고 사유를 사용하여 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '신고가 완료 되었습니다.',
                style: medium13.copyWith(
                    fontSize: screenWidth * 0.033, color: Colors.white),
              ),
            ),
          );
          reportUser(targetUid, value);
        }
      });
    }

    /// 리뷰 아이템의 드롭다운 메뉴 위젯
    Widget reviewDropDown(double screenHeight, double screenWidth,
        String targetUid, GlobalKey key) {
      return Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.8),
        child: PopupMenuButton<String>(
          key: key,
          color: Colors.white,
          elevation: 1,
          icon: const Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
          onSelected: (String value) {
            if (value == 'report') {
              // 위젯의 위치를 가져와서 신고 메뉴 표시
              final RenderBox renderBox =
                  key.currentContext!.findRenderObject() as RenderBox;
              final Offset position = renderBox.localToGlobal(Offset.zero);
              showReportMenu(context, position, targetUid);
            } else if (value == 'block') {
              blockDialog(targetUid);
            }
          },
          itemBuilder: (BuildContext context) {
            // 메뉴 아이템 리스트를 동적으로 생성합니다.
            List<PopupMenuEntry<String>> menuItems = [
              PopupMenuItem<String>(
                value: 'report',
                child: Text(
                  '신고하기',
                  style: medium13.copyWith(fontSize: screenWidth * 0.033),
                ),
              ),
            ];

            // 현재 사용자와 타겟 사용자가 다를 때만 '차단하기' 옵션을 추가합니다.
            if (currentUserId != targetUid) {
              menuItems.add(
                PopupMenuItem<String>(
                  value: 'block',
                  child: Text(
                    '차단하기',
                    style: medium13.copyWith(fontSize: screenWidth * 0.033),
                  ),
                ),
              );
            }

            return menuItems;
          },
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.025),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('locationMap')
                .doc(widget.tourId)
                .collection('visitor')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // 모든 리뷰를 가져옵니다.
              var allVisitorReviews = snapshot.data!.docs;

              // 차단된 사용자의 UID를 포함하지 않는 리뷰만 필터링합니다.
              var visitor = allVisitorReviews.where((review) {
                return !blockedUsers.contains(review['uid']);
              }).toList();

              return Column(
                children: [
                  // 평균 별점 및 리뷰 수를 표시하는 부분
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color:
                                index < averageScore(allVisitorReviews).round()
                                    ? AppColor.button
                                    : Colors.grey,
                            size: screenWidth * 0.09,
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Row(
                        children: [
                          Text(
                            averageScore(allVisitorReviews).toStringAsFixed(1),
                            style:
                                medium20.copyWith(fontSize: screenWidth * 0.05),
                          ),
                          Text(
                            '/5 ',
                            style: medium20.copyWith(
                              color: const Color.fromRGBO(173, 170, 170, 1),
                              fontSize: screenWidth * 0.05,
                            ),
                          ),
                          Text(
                            '(${allVisitorReviews.length})',
                            style: regular13.copyWith(
                              color: const Color.fromRGBO(173, 170, 170, 1),
                              fontSize: screenWidth * 0.033,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Divider(color: Color(0xffF3F3F3)),
                  // 리뷰 제목 부분
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.065,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "리뷰",
                          style:
                              medium20.copyWith(fontSize: screenWidth * 0.05),
                        ),
                        Text(
                          " ${visitor.length}",
                          style: medium20.copyWith(
                            color: const Color(0xffadaaaa),
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color.fromRGBO(178, 178, 178, 0.4)),
                  // 이미지 리뷰를 표시하는 부분
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.065),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        3,
                        (index) => (visitor.length > index &&
                                visitor[index]['reviewImageUrl'] != null)
                            ? GestureDetector(
                                onTap: index == 2
                                    ? () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PhotoReviewTourPage(
                                                      courseId: widget.tourId,
                                                    )));
                                      }
                                    : null,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: AppColor.button),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          visitor[index]['reviewImageUrl'],
                                          width: screenWidth * 0.27,
                                          height: screenHeight * 0.12,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    if (index == 2)
                                      Container(
                                        width: screenWidth * 0.27,
                                        height: screenHeight * 0.12,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              0, 0, 0, 0.5),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    if (index == 2)
                                      Positioned(
                                        left: screenWidth * 0.05,
                                        top: screenHeight * 0.047,
                                        child: Text(
                                          '+ 더보기',
                                          style: medium15.copyWith(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.04,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : Container(
                                width: screenWidth * 0.27,
                                height: screenHeight * 0.12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: AppColor.button,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const Divider(color: Color.fromRGBO(178, 178, 178, 0.4)),
                  // 리뷰 리스트를 표시하는 부분
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visitor.length,
                    itemBuilder: (context, index) {
                      var review = visitor[index];
                      var targetUserId = review['uid']; // 리뷰 작성자의 UID
                      GlobalKey key = GlobalKey();

                      return Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.065),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Row(
                                  children: [
                                    // 리뷰 이미지 표시
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
                                                width: screenWidth * 0.27,
                                                height: screenHeight * 0.12,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            width: screenWidth * 0.27,
                                            height: screenHeight * 0.12,
                                          ),
                                    SizedBox(width: screenWidth * 0.03),
                                    // 리뷰 내용 및 사용자 정보 표시
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '이름',
                                              style: medium15.copyWith(
                                                color: const Color(0xff7A7A7A),
                                                fontSize: screenWidth * 0.038,
                                              ),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.014),
                                            Text(
                                              '장소',
                                              style: medium15.copyWith(
                                                color: const Color(0xff7A7A7A),
                                                fontSize: screenWidth * 0.038,
                                              ),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.014),
                                            Text(
                                              '별점',
                                              style: medium15.copyWith(
                                                color: const Color(0xff7A7A7A),
                                                fontSize: screenWidth * 0.038,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: screenWidth * 0.05),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${review['username']}',
                                              style: medium15.copyWith(
                                                  fontSize:
                                                      screenWidth * 0.038),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.014),
                                            Text(
                                              widget.tourTitle,
                                              style: medium15.copyWith(
                                                  fontSize:
                                                      screenWidth * 0.038),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.014),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (starIndex) => Icon(
                                                  Icons.star,
                                                  color: starIndex <
                                                          review['score']
                                                              .toInt()
                                                      ? AppColor.button
                                                      : Colors.grey,
                                                  size: screenWidth * 0.05,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // 리뷰 옵션 드롭다운 메뉴 (신고하기, 차단하기)
                                Positioned(
                                  right: 0,
                                  child: reviewDropDown(screenHeight,
                                      screenWidth, targetUserId, key),
                                ),
                              ],
                            ),
                            // 리뷰 텍스트 표시
                            Padding(
                              padding: EdgeInsets.only(
                                top: screenHeight * 0.027,
                                bottom: screenHeight * 0.017,
                                right: screenWidth * 0.065,
                              ),
                              child: Text(
                                review['review'],
                                style: regular15.copyWith(
                                  fontSize: screenWidth * 0.038,
                                ),
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
