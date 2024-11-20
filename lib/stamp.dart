import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme/text.dart';

class StampPage extends StatefulWidget {
  const StampPage({super.key});

  @override
  _StampPageState createState() => _StampPageState();
}

class _StampPageState extends State<StampPage> {
  final String formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
  List<Map<String, dynamic>> stamps = [];
  String nickName = "";

  @override
  void initState() {
    super.initState();
    fetchStampData();
  }

  Future<void> fetchStampData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      nickName = userDoc['nickName'];
      List<dynamic> stampIds = userDoc['stampId'];

      for (String stampId in stampIds) {
        DocumentSnapshot stampDoc = await FirebaseFirestore.instance
            .collection('stamp')
            .doc(stampId)
            .get();
        if (stampDoc.exists) {
          Map<String, dynamic> stampData =
              stampDoc.data() as Map<String, dynamic>;
          stamps.add({
            'name': stampData['stampName'],
            'image': stampData['stampImageUrl'],
            'location': stampData['location'],
          });
        }
      }

      while (stamps.length < 6) {
        stamps.add({'name': '', 'image': '', 'location': ''});
      }

      setState(() {});
    } catch (e) {
      print('Error fetching stamp data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                "assets/ul.png",
                width: double.infinity,
                height: screenHeight * 0.43,
                fit: BoxFit.cover,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.08),
                  child: Text(
                    "스탬프",
                    style: medium20.copyWith(
                      fontSize: (20 / 393) * screenWidth,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.2),
                  child: Text(
                    "울릉도 곳곳에 숨어있는\n동물 친구들을 찾아주세요!",
                    textAlign: TextAlign.center,
                    style: medium20.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.7,
                      letterSpacing: -0.32,
                      fontSize: (20 / 393) * screenWidth,
                    ),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: SizedBox(
              height: 500,
              child: GridView.count(
                crossAxisCount: 3,
                padding: EdgeInsets.all(screenWidth * 0.04),
                children: stamps.map((stamp) {
                  return StampItem(
                    name: stamp['name'],
                    image: stamp['image'],
                    location: stamp['location'],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StampItem extends StatelessWidget {
  final String name;
  final String image;
  final String location;

  const StampItem({
    super.key,
    required this.name,
    required this.image,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    double mediaHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: image.isNotEmpty
          ? () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Center(
                      child: Text(
                        '$name 스탬프',
                        style: extrabold24.copyWith(
                          color: const Color(0xff1E528E),
                          fontSize: mediaWidth * 0.06,
                        ),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: mediaWidth * 0.7,
                          height: mediaHeight * 0.23,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color(0xffEEF4FF),
                          ),
                          child: Image.network(
                            image,
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(height: mediaHeight * 0.03),
                        Text(
                          '$location 플로깅 완료',
                          style: medium16.copyWith(fontSize: mediaWidth * 0.04),
                        ),
                        SizedBox(height: mediaHeight * 0.03),
                        Text(
                          '일시: 2024.06.27 / 14:27 \n거리: 1.5km',
                          style: medium15.copyWith(fontSize: mediaWidth * 0.04),
                        ),
                        SizedBox(height: mediaHeight * 0.03),
                        Container(
                          width: mediaWidth * 0.7,
                          height: mediaHeight * 0.05,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffA3C2FF)),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Center(
                            child: Text(
                              '10마리의 해양생물이 고마워하고 있어요!',
                              style: medium13.copyWith(
                                  fontSize: mediaWidth * 0.033),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff50A2FF),
                        ),
                        child: Text(
                          "닫기",
                          style: bold15.copyWith(
                              color: Colors.white,
                              fontSize: (15 / 393) * mediaWidth),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          : null,
      child: Column(
        children: [
          (image.isEmpty)
              ? SizedBox()
              : Image.network(
                  image,
                  fit: BoxFit.contain,
                ),
          SizedBox(height: mediaHeight * 0.01),
          Text(
            name,
            style: regular15.copyWith(fontSize: mediaWidth * 0.038),
          ),
        ],
      ),
    );
  }
}
