import "package:flutter/material.dart";
import "package:ssoup_new/theme/text.dart";

class TransportationPage extends StatelessWidget {
  const TransportationPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            const SizedBox(height: 30),
            Text('이동수단',
                style: medium20.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 0.07,
                  letterSpacing: -0.32,
                )),
            const SizedBox(height: 9),
            Divider(
              indent: (15 / 393) * screenWidth,
              endIndent: (15 / 393) * screenWidth,
            ),
          ],
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 29),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/taxi_page");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/taxi.png',
                        width: 343,
                        height: 263,
                      ),
                      Positioned(
                        top: 21,
                        left: 16,
                        child: Text(
                          '이동이 어려운 울릉도, \n지금 바로 콜택시를 콜 해보세요!',
                          style: medium20.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.32,
                            height: 1.05,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 224,
                        left: 16,
                        child: Text(
                          '울릉도 콜택시 리스트를 모아봤어요',
                          style: medium13.copyWith(
                            color: const Color(0xFF858585),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.32,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/boat_page");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/boat.png',
                        width: 343,
                        height: 263,
                      ),
                      Positioned(
                        top: 21,
                        left: 16,
                        child: Text(
                          '울릉도 방문 필수코스,\n독도 배편을 예약해보세요 !',
                          style: medium20.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.32,
                            height: 1.05,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 224,
                        left: 16,
                        child: Text(
                          '독도 배편 예약 링크 바로가기',
                          style: medium13.copyWith(
                            color: const Color(0xFF858585),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.32,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
