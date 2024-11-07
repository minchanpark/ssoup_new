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
      if (e.code == 'user-not-found') {
        message = '등록되지 않은 사용자입니다. 먼저 회원가입 해주세요.';
      } else if (e.code == 'wrong-password') {
        message = '비밀번호가 일치하지 않습니다.';
      } else {
        message = '알 수 없는 에러가 발생하였습니다.';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '로그인',
          style: bold15.copyWith(
            fontWeight: FontWeight.w600,
            height: 0.05,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "*아이디",
                  style: medium15.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    height: 0.09,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _idController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: '5~20자의 영문, 영문+숫자를 이메일 형식으로 입력해주세요',
                    hintStyle: medium15.copyWith(
                      color: const Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
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
                const SizedBox(height: 30.0),
                Text(
                  "*비밀번호",
                  style: medium15.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    height: 0.09,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // To obscure the password input
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요',
                    hintStyle: medium15.copyWith(
                      color: const Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w500,
                      height: 0.12,
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
                const SizedBox(height: 294.0),
                SizedBox(
                  width: 336,
                  height: 47,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF6FA0E6)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
