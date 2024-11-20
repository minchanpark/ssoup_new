import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ssoup_new/theme/text.dart';
import 'package:url_launcher/url_launcher.dart';

class BoatPage extends StatelessWidget {
  const BoatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final List<Map<String, String>> ferryData = [
      {
        'time': '07:20',
        'company': '씨스포빌주식회사',
        'duration': '1시간 35분',
      },
      {
        'time': '08:20',
        'company': '(주)대저해운',
        'duration': '1시간 30분',
      },
      {
        'time': '09:10',
        'company': '대아고속해운',
        'duration': '1시간 30분',
      },
      {
        'time': '12:30\n(매주 금)',
        'company': '씨스포빌주식회사',
        'duration': '1시간 35분',
      },
      {
        'time': '13:40',
        'company': '씨스포빌주식회사',
        'duration': '1시간 35분',
      },
      {
        'time': '15:00',
        'company': '대아고속해운',
        'duration': '1시간 30분',
      },
      {
        'time': '16:00\n(매주 토)',
        'company': '씨스포빌주식회사',
        'duration': '1시간 35분',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '독도 배편 예약 링크',
          style: medium16.copyWith(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w500,
            height: 0.07,
            letterSpacing: -0.32,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Divider(
            indent: screenWidth * 0.06,
            endIndent: screenWidth * 0.06,
          ),
          Padding(
            padding: EdgeInsets.only(
              right: screenWidth * 0.71,
              top: screenHeight * 0.04,
              bottom: screenHeight * 0.008,
            ),
            child: Text(
              '울릉출항',
              style: medium15.copyWith(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
                height: 0.09,
                letterSpacing: -0.32,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ferryData.length,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              itemBuilder: (context, index) {
                return Container(
                  width: screenWidth * 0.87,
                  height: screenHeight * 0.13,
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: const Color(0xFF4FA2FF),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ferryData[index]['time']!,
                        style: bold15.copyWith(
                          color: const Color(0xFF4367AD),
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.32,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ferryData[index]['company']!,
                            style: regular13.copyWith(
                              fontSize: screenWidth * 0.033,
                              fontWeight: FontWeight.w200,
                              height: 0.12,
                              letterSpacing: -0.32,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            '소요시간 : ${ferryData[index]['duration']}',
                            style: medium16.copyWith(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.32,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          if (ferryData[index]['company'] == "씨스포빌주식회사") {
                            final url = Uri.parse(
                                'https://seaspovill.co.kr/ticket.php?id=k1');
                            launchUrl(url);
                          } else if (ferryData[index]['company'] == "(주)대저해운") {
                            final url = Uri.parse(
                                'https://island.theksa.co.kr/iframe/page/booking?sourcesiteid=D6KGUFV5BKUY4IWALYXP&maintainmain=1&ismain=1');
                            launchUrl(url);
                          } else if (ferryData[index]['company'] == "대아고속해운") {
                            final url = Uri.parse(
                                'https://www.jhferry.com/bookingHW/booking.html');
                            launchUrl(url);
                          }
                        },
                        icon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/arrow_up.svg",
                              color: Colors.blue,
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.04,
                            ),
                            Text(
                              '바로가기',
                              style: regular10.copyWith(
                                color: const Color(0xFF4FA2FF),
                                fontSize: screenWidth * 0.033,
                                fontWeight: FontWeight.w200,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF4FA2FF),
                                height: 0.21,
                                letterSpacing: -0.32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
