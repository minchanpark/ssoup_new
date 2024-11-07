import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'theme/color.dart';

class NickNamePage extends StatefulWidget {
  const NickNamePage({super.key});

  @override
  State<NickNamePage> createState() => _NickNamePageState();
}

class _NickNamePageState extends State<NickNamePage> {
  final TextEditingController nickNameController = TextEditingController();
  bool isNickNameFilled = false;

  @override
  void initState() {
    super.initState();
    nickNameController.addListener(_checkNickNameInput);
  }

  void _checkNickNameInput() {
    setState(() {
      isNickNameFilled = nickNameController.text.isNotEmpty;
    });
  }

  Future<void> addNickNameToFirestore(String nickName) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;

    if (user != null) {
      final users = FirebaseFirestore.instance.collection('user');
      final snapshot = await users.doc(user.uid).get();

      if (snapshot.exists) {
        await users.doc(user.uid).update({'nickName': nickName});
        print('Nickname updated in Firestore: $nickName');
      } else {
        await users.doc(user.uid).set({
          'uid': user.uid,
          'nickName': nickName,
        });
        print('New user data with nickname added to Firestore: $nickName');
      }
    } else {
      print('No user is currently signed in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.13,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "닉네임 설정",
                    style: TextStyle(
                      fontFamily: 'SCDream5',
                      fontSize: 18,
                      color: AppColor.mainText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "한번 설정한 닉네임은 수정할 수 없으니 신중하게 설정하세요!",
                    style: TextStyle(
                      fontFamily: 'SCDream3',
                      fontSize: 12,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                width: 250,
                height: 38,
                child: TextFormField(
                  controller: nickNameController,
                  cursorColor: Colors.blue,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    hintText: "사용할 닉네임을 입력하세요",
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'SCDream3',
                      color: AppColor.mainText,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.22),
            Image.asset(
              "assets/nickname_fish.png",
              width: screenWidth * 0.32,
              height: screenHeight * 0.2,
            ),
            SizedBox(height: screenHeight * 0.09),
            Opacity(
              opacity: isNickNameFilled ? 1.0 : 0.6,
              child: ElevatedButton(
                onPressed: isNickNameFilled
                    ? () {
                        addNickNameToFirestore(nickNameController.text);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home_page_navigationBar',
                          (Route<dynamic> route) => false,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColor.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  fixedSize: Size(
                    screenWidth * 0.7,
                    screenHeight * 0.067,
                  ),
                ),
                child: const Text(
                  "시작하기",
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 16,
                    fontFamily: 'SCDream5',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.08),
            const Text(
              "버전 0.1",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.32,
                fontFamily: 'SCDream3',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
