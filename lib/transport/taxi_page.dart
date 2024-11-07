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
            fontSize: 18,
            height: 0.07,
            letterSpacing: -0.32,
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(
            indent: (25 / 393) * screenWidth,
            endIndent: (25 / 393) * screenWidth,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: taxiData.length,
              padding: EdgeInsets.only(
                right: (25 / 393) * screenWidth,
                left: (25 / 393) * screenWidth,
                top: (15 / 852) * screenHeight,
              ),
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      EdgeInsets.symmetric(vertical: (5 / 852) * screenHeight),
                  padding: EdgeInsets.only(left: (17 / 393) * screenWidth),
                  width: 343,
                  height: 84,
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
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.32,
                              ),
                            ),
                            if (taxiData[index]['info']!.isNotEmpty)
                              Text(
                                taxiData[index]['info']!,
                                style: regular13.copyWith(
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: -0.32,
                                ),
                              ),
                            Row(
                              children: [
                                const Icon(
                                  FluentIcons.call_20_regular,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                Text(
                                  taxiData[index]['phone']!,
                                  style: regular10.copyWith(
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: -0.32,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          FluentIcons.call_20_regular,
                          color: Colors.blue,
                          size: 45,
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
          SizedBox(
            height: (30 / 852) * screenHeight,
            child: Text(
              '*네이버 기준 영업등록된 콜택시입니다.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
