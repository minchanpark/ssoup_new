import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../about_home/home_navigationbar.dart';
import '../theme/text.dart';

class LoginWithId extends StatefulWidget {
  const LoginWithId({super.key});

  @override
  _LoginWithIdState createState() => _LoginWithIdState();
}

class _LoginWithIdState extends State<LoginWithId> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form not valid
    }

    setState(() {
      _isLoading = true; // Start loading indicator
    });

    String id = _idController.text;
    String password = _passwordController.text;

    try {
      // Sign in with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: id, // Assuming 'id' is the email
        password: password,
      );

      User user = userCredential.user!;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("user")
          .doc(user.uid)
          .get();

      // Check if user exists in Firestore and if they have a nickname
      if (userDoc.exists && userDoc['nickName'] == null) {
        // Navigate to nickname page
        Navigator.pushNamed(context, "/nick_name_page");
      } else {
        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePageNavigationBar()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'invalid-email') {
        message = '등록되지 않은 사용자입니다. 먼저 회원가입 해주세요.';
      } else if (e.code == 'invalid-credential') {
        message = '비밀번호가 일치하지 않습니다.';
      } else {
        //위에서 처리되지 않는 에러들에 대해서 출력할 에러 메세지
        message = '알 수 없는 에러가 발생하였습니다. 다시 시도해주세요.';
      }

      // Show error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    double appHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          '로그인',
          style: bold15.copyWith(
            fontWeight: FontWeight.w600,
            height: 0.05,
            fontSize: (20 / 393) * appWidth,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all((28.0 / 393) * appWidth),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: (10 / 852) * appHeight),
                Text(
                  "*아이디",
                  style: medium15.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    height: 0.09,
                    fontSize: (15 / 393) * appWidth,
                  ),
                ),
                SizedBox(height: (5 / 852) * appHeight),
                TextFormField(
                  controller: _idController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: '5~20자의 영문, 영문+숫자를 이메일 형식으로 입력해주세요',
                    hintStyle: medium15.copyWith(
                      color: const Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w500,
                      fontSize: (12 / 393) * appWidth,
                    ),
                    border: const UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '아이디를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: (30.0 / 852) * appHeight),
                Text(
                  "*비밀번호",
                  style: medium15.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    height: 0.09,
                    fontSize: (15 / 393) * appWidth,
                  ),
                ),
                SizedBox(height: (5 / 852) * appHeight),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // To obscure the password input
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요',
                    hintStyle: medium15.copyWith(
                      color: const Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w500,
                      height: 0.12,
                      fontSize: (12 / 393) * appWidth,
                    ),
                    border: const UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: (294.0 / 852) * appHeight),
                SizedBox(
                  width: (336 / 393) * appWidth,
                  height: (47 / 852) * appHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0xFF6FA0E6)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular((12 / 393) * appWidth),
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            '로그인 하기',
                            textAlign: TextAlign.center,
                            style: medium16.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 0.08,
                              color: Colors.white,
                              fontSize: (16 / 393) * appWidth,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
