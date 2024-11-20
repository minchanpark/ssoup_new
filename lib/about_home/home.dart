import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../location/tour_list.dart';
import '../theme/text.dart';
import 'custom_progress_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;
    User? user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: (70 / 852) * appHeight,
        title: Row(
          children: [
            SizedBox(width: (10 / 393) * appWidth),
            Container(
              width: (76 / 393) * appWidth,
              height: (48 / 852) * appHeight,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/setting_page');
            },
            icon: SvgPicture.asset(
              'assets/setting_line_light.svg',
              width: (33 / 393) * appWidth,
              height: (33 / 852) * appHeight,
            ),
          ),
          SizedBox(width: (10 / 393) * appWidth),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: (22 / 852) * appHeight),
            (uid == null || uid.isEmpty)
                ? const SizedBox()
                : const CustomProgressBar(),

            SizedBox(
              width: appWidth,
              child: Image.asset(
                'assets/ul.png',
                fit: BoxFit.cover,
              ),
            ),
            // 버튼 섹션
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: (16.0 / 393) * appWidth),
              child: Column(
                children: [
                  // 울릉도 관광명소 버튼
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      overlayColor: Colors.blue,
                      side:
                          const BorderSide(color: Color(0xff79BFF4), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular((10 / 393) * appWidth),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TourListPage()));
                    },
                    child: SizedBox(
                      width: (342 / 393) * appWidth,
                      height: (84 / 852) * appHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/home_map.png',
                                width: (34 / 393) * appWidth,
                                height: (34 / 852) * appHeight,
                              ),
                              SizedBox(width: (17 / 393) * appWidth),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '울릉도 관광명소',
                                    style: medium15.copyWith(
                                      fontSize: (18 / 393) * appWidth,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/arrow.png',
                                        width: (14 / 393) * appWidth,
                                        height: (14 / 852) * appHeight,
                                      ),
                                      SizedBox(width: (4 / 393) * appWidth),
                                      Text(
                                        '관광지 100곳',
                                        style: regular10.copyWith(
                                          fontSize: (12 / 393) * appWidth,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: (76 / 393) * appWidth,
                            height: (26 / 852) * appHeight,
                            decoration: ShapeDecoration(
                              color: const Color(0xff8ECCFC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    (12 / 393) * appWidth),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '관광하기',
                                style: medium13.copyWith(
                                  fontSize: (12 / 393) * appWidth,
                                  fontWeight: FontWeight.w500,
                                  height: 0.21,
                                  letterSpacing: -0.32,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: (19 / 852) * appHeight),
                  // 울릉도 플로깅 버튼
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      overlayColor: Colors.blue,
                      side:
                          const BorderSide(color: Color(0xff79BFF4), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular((10 / 393) * appWidth),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/plogging_page");
                    },
                    child: SizedBox(
                      width: (342 / 393) * appWidth,
                      height: (84 / 852) * appHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/person.png',
                                width: (34 / 393) * appWidth,
                                height: (34 / 852) * appHeight,
                              ),
                              SizedBox(width: (17 / 393) * appWidth),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '울릉도 플로깅',
                                    style: medium15.copyWith(
                                      fontSize: (18 / 393) * appWidth,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/happy.png',
                                        width: (14 / 393) * appWidth,
                                        height: (14 / 852) * appHeight,
                                      ),
                                      SizedBox(width: (4 / 393) * appWidth),
                                      Text(
                                        '플로깅 인증하고 선물받기',
                                        style: regular10.copyWith(
                                          fontSize: (12 / 393) * appWidth,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: (76 / 393) * appWidth,
                            height: (26 / 852) * appHeight,
                            decoration: ShapeDecoration(
                              color: const Color(0xff8ECCFC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    (12 / 393) * appWidth),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '플로깅하기',
                                style: medium13.copyWith(
                                  fontSize: (12 / 393) * appWidth,
                                  fontWeight: FontWeight.w500,
                                  height: 0.21,
                                  letterSpacing: -0.32,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: (42 / 852) * appHeight),
          ],
        ),
      ),
    );
  }
}
