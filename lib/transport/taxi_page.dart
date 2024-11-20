import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:ssoup_new/theme/text.dart';
import 'package:url_launcher/url_launcher.dart';

class TaxiPage extends StatelessWidget {
  const TaxiPage({Key? key}) : super(key: key);

  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final List<Map<String, String>> taxiData = [
      {
        'name': '울릉도 개인콜택시 울릉군지부',
        'info': '24시간 영업 / 연중무휴',
        'phone': '054-791-0006',
      },
      {
        'name': '울릉 택시 협동조합',
        'info': '',
        'phone': '054-791-4002',
      },
      {
        'name': '(개인)개인택시 경북 16바 7033',
        'info': '22:00에 영업종료',
        'phone': '0507-1345-4724',
      },
      {
        'name': '(개인)개인택시 경북 16바 7011',
        'info': '24시간 영업 / 연중무휴',
        'phone': '0507-1387-1166',
      },
      {
        'name': '(개인)개인택시 경북 16바 7029',
        'info': '22:00에 영업종료',
        'phone': '0507-1445-9876',
      },
      {
        'name': '(개인)윤선생의 울릉도택시',
        'info': '24:00에 영업종료',
        'phone': '010-6533-6730',
      },
      {
        'name': '(개인)개인택시',
        'info': '24:00에 영업종료',
        'phone': '0507-1355-6123',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '울릉도 콜택시',
          style: medium15.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.045,
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
          Expanded(
            child: ListView.builder(
              itemCount: taxiData.length,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  padding: EdgeInsets.only(left: screenWidth * 0.04),
                  width: screenWidth * 0.87,
                  height: screenHeight * 0.11,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFF4FA2FF),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              taxiData[index]['name']!,
                              style: medium16.copyWith(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.32,
                              ),
                            ),
                            if (taxiData[index]['info']!.isNotEmpty)
                              Text(
                                taxiData[index]['info']!,
                                style: regular13.copyWith(
                                  fontSize: screenWidth * 0.033,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: -0.32,
                                ),
                              ),
                            Row(
                              children: [
                                Icon(
                                  FluentIcons.call_20_regular,
                                  color: Colors.blue,
                                  size: screenWidth * 0.05,
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  taxiData[index]['phone']!,
                                  style: regular10.copyWith(
                                    fontSize: screenWidth * 0.033,
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: -0.32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          FluentIcons.call_20_regular,
                          color: Colors.blue,
                          size: screenWidth * 0.1,
                        ),
                        onPressed: () =>
                            _makePhoneCall(taxiData[index]['phone']!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: Text(
              '*네이버 기준 영업등록된 콜택시입니다.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: screenWidth * 0.03,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
