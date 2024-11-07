import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssoup_new/theme/text.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _passwordError = '';

  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase Authentication instance

  // ID validation
  bool _validateId(String id) {
    final idRegex = RegExp(r'^[a-zA-Z0-9]{5,20}$');
    return idRegex.hasMatch(id);
  }

  // Password confirmation validation
  bool _confirmPassword(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  Future<void> addUserToFirestore(User user, String email, String name) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('user');
    final DocumentSnapshot snapshot = await users.doc(user.uid).get();

    if (snapshot.exists) {
      final updatedUserData = {'name': name};
      await users.doc(user.uid).update(updatedUserData);
      print('User data updated in Firestore: $updatedUserData');
    } else {
      final newUserData = {
        'uid': user.uid,
        'email': email,
        'name': name,
        'totalSpot': 0,
        'totalStamp': 0,
        'totalKm': 0.0,
        'nickName': '',
        'stampId': [],
      };
      await users.doc(user.uid).set(newUserData);
      print('New user data added to Firestore: $newUserData');
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _passwordError = _confirmPassword(
              _passwordController.text, _passwordConfirmController.text)
          ? ''
          : '비밀번호가 일치하지 않습니다';
    });

    if (_passwordError.isEmpty) {
      try {
        // Create a new user with Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Add the user to Firestore
        await addUserToFirestore(
            userCredential.user!, _emailController.text, _nameController.text);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('회원가입 완료'),
        ));

        Navigator.pushNamed(context, "/nick_name_page");
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('회원가입 오류: ${e.message}'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          '회원가입',
          style: bold15.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 0.05,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('*이메일',
                  style: medium15.copyWith(fontWeight: FontWeight.w500)),
              TextField(
                controller: _emailController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  hintText: '0000.00.00',
                  hintStyle: medium15.copyWith(
                    color: const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w500,
                    height: 0.12,
                  ),
                ),
              ),
              SizedBox(height: (22 / 852) * appHeight),
              Text(
                '*비밀번호',
                style: medium15.copyWith(fontWeight: FontWeight.w500),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: '비밀번호를 입력해주세요',
                  hintStyle: medium15.copyWith(
                    color: const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w500,
                    height: 0.12,
                  ),
                ),
              ),
              SizedBox(height: (22 / 852) * appHeight),
              Text(
                '*비밀번호 확인',
                style: medium15.copyWith(fontWeight: FontWeight.w500),
              ),
              TextField(
                controller: _passwordConfirmController,
                obscureText: true,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: '비밀번호를 한번 더 입력해주세요',
                  hintStyle: medium15.copyWith(
                    color: const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w500,
                    height: 0.12,
                  ),
                  errorText: _passwordError.isNotEmpty ? _passwordError : null,
                ),
              ),
              SizedBox(height: (22 / 852) * appHeight),
              Text(
                '*이름',
                style: medium15.copyWith(fontWeight: FontWeight.w500),
              ),
              TextField(
                controller: _nameController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: '예) 홍길동',
                  hintStyle: medium15.copyWith(
                    color: const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w500,
                    height: 0.12,
                  ),
                ),
              ),
              SizedBox(height: (51 / 852) * appHeight),
              SizedBox(
                width: 336,
                height: 47,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ButtonStyle(
                    backgroundColor:
                        const WidgetStatePropertyAll(Color(0xFF6FA0E6)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: Text(
                    '가입하기',
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
    );
  }
}
