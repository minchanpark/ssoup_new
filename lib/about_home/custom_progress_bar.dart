import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ssoup_new/theme/text.dart';

class CustomProgressBar extends StatefulWidget {
  const CustomProgressBar({super.key});

  @override
  State<CustomProgressBar> createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar> {
  Stream<List<dynamic>> getStampIds() {
    String uid = FirebaseAuth.instance.currentUser!.uid; // 현재 사용자 UID 가져오기
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .snapshots() // 실시간 스트림으로 변경
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot['stampId'];
      } else {
        throw Exception("User document does not exist");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;
    return StreamBuilder<List<dynamic>>(
      stream: getStampIds(), // 실시간 데이터 스트림
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로딩 중일 때 표시
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}"); // 에러 처리
        }

        List<dynamic> stampIds = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: (115 / 393) * appWidth),
              child: Opacity(
                opacity: 0.60,
                child: Text(
                  '내가 모은 스탬프',
                  style: medium13.copyWith(
                    fontSize: (10 / 393) * appWidth,
                    fontWeight: FontWeight.w500,
                    height: 0.21,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: (25 / 393) * appWidth),
                Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    // Progress bar background
                    Container(
                      width: (256 / 393) * appWidth,
                      height: (26 / 852) * appHeight,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Color(0xFF5573AC)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    // Filled portion of progress bar
                    Container(
                      width: (222 / 393) * appWidth,
                      height: (16 / 852) * appHeight,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF8ECCFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // White portion of progress bar
                    //내가 모은 스탬프 개수대로 progressbar가 채워진다.
                    //흰색 원에 가려진 부분을 제외하고 나머지 부분을 6등분하여서 한 부분당 29.6px이다.
                    //아래에 있는 코드 중 5를 내가 얻은 스탬프의 개수로 바꾸면 될 것 같다.
                    Container(
                      width: (stampIds.isEmpty)
                          ? (46 / 393) * appWidth
                          : (46 + (29.6 * stampIds.length)) /
                              393 *
                              appWidth, // 반응형 너비
                      height: (10 / 852) * appHeight,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // Text displaying progress
                    Positioned(
                      left: (227 / 393) * appWidth,
                      child: Text(
                        '${stampIds.length}/6',
                        style: medium13.copyWith(
                          fontSize: (10 / 393) * appWidth,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Circular marker
                    Container(
                      width: (45 / 393) * appWidth,
                      height: (45 / 393) * appWidth,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(width: 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
