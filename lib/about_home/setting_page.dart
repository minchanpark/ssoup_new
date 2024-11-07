import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ssoup_new/main.dart';
import 'package:ssoup_new/theme/text.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String nickName = '';

  Future<void> fetchNickName() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      nickName = userDoc['nickName'];
      setState(() {});
    } catch (e) {
      print('Error fetching nickName data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNickName();
  }

  void _logout() {
    try {
      FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false, // 모든 이전 페이지 스택을 제거
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  void _deleteAccount() {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // 1. Firestore에서 사용자 데이터 삭제 (선택 사항)
      FirebaseFirestore.instance.collection('user').doc(uid).delete();

      // 2. Firebase Authentication에서 사용자 삭제
      FirebaseAuth.instance.currentUser!.delete();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false, // 모든 이전 페이지 스택을 제거
      );
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('회원탈퇴'),
          content: const Text('정말로 회원탈퇴를 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                '취소',
                style: medium13.copyWith(color: Color(0xFF1A86FF)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '탈퇴',
                style: medium13.copyWith(color: Color(0xff9D9D9D)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _deleteAccount(); // 회원탈퇴 처리
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            Padding(
              padding: EdgeInsets.only(
                left: (25 / 393) * appWidth,
                top: (14 / 852) * appHeight,
                bottom: (34 / 852) * appHeight,
              ),
              child: Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: OvalBorder(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$nickName 님',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: -0.32,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, height: 2, color: Color(0xffB1B1B1)),

            // 메뉴 항목 리스트
            Column(
              children: [
                _buildMenuItem('서비스 이용약관', 0),
                const Divider(
                    thickness: 1, height: 2, color: Color(0xffB1B1B1)),
                _buildMenuItem('개인정보 처리방침', 1),
                const Divider(
                    thickness: 1, height: 2, color: Color(0xffB1B1B1)),
                _buildMenuItem('로그아웃', 2),
                const Divider(
                    thickness: 1, height: 2, color: Color(0xffB1B1B1)),
                _buildMenuItem('회원탈퇴', 3),
                const Divider(
                    thickness: 1, height: 2, color: Color(0xffB1B1B1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 메뉴 항목을 쉽게 만들기 위한 헬퍼 함수
  Widget _buildMenuItem(String title, int index) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.32,
        ),
      ),
      onTap: () {
        if (index == 0) {
          Navigator.pushNamed(context, "/service");
        } else if (index == 1) {
          Navigator.pushNamed(context, "/private");
        } else if (index == 2) {
          _logout(); // 로그아웃 기능
        } else if (index == 3) {
          _showDeleteAccountDialog(); // 회원탈퇴 기능
        }
      },
    );
  }
}
