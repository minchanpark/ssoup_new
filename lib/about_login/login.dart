import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:ssoup_new/about_login/register_page.dart';
import '../about_home/home_navigationbar.dart';
import '../nick_name.dart';
import '../theme/text.dart';

Future<bool> isLoginMethodMatching(String? email, String loginMethod) async {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('user');

  // 이메일이 일치하는 유저 문서 조회
  final QuerySnapshot result =
      await users.where('email', isEqualTo: email).get();

  // 해당 이메일로 등록된 유저가 있는지 확인
  if (result.docs.isNotEmpty) {
    final userData = result.docs.first.data() as Map<String, dynamic>;

    // loginMethod가 일치하는지 확인
    return userData['loginMethod'] == loginMethod;
  }

  return false; // 유저가 없거나 loginMethod가 일치하지 않으면 false
}

Future<void> addUserToFirestore(firebase_auth.User user, String email,
    String name, String loginMethod) async {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('user');
  final DocumentSnapshot snapshot = await users.doc(user.uid).get();

  if (snapshot.exists) {
    final updatedUserData = {
      'email': email,
      'name': name,
      'loginMethod': loginMethod,
    };
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
      'loginMethod': loginMethod,
    };
    await users.doc(user.uid).set(newUserData);
    print('New user data added to Firestore: $newUserData');
  }
}

Future<firebase_auth.UserCredential> signInWithKakao() async {
  try {
    final kakao.OAuthToken token =
        await kakao.UserApi.instance.loginWithKakaoAccount();
    print('Kakao login successful: ${token.accessToken}');

    final kakao.User kakaoUser = await kakao.UserApi.instance.me();
    final email = kakaoUser.kakaoAccount?.email ?? '';
    final name = kakaoUser.kakaoAccount?.profile?.nickname ?? '';

    // Firestore에서 loginMethod 일치 여부 확인
    isLoginMethodMatching(email, 'Kakao');

    final credential = firebase_auth.OAuthProvider("oidc.kakao.com").credential(
      accessToken: token.accessToken,
      idToken: token.idToken ?? '',
    );

    final userCredential = await firebase_auth.FirebaseAuth.instance
        .signInWithCredential(credential);
    final firebase_auth.User? user = userCredential.user;

    if (user == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'ERROR_USER_NOT_FOUND',
        message: 'Firebase user not found after Kakao login',
      );
    }

    print('Firebase user authenticated: ${user.uid}');
    await addUserToFirestore(user, email, name, 'Kakao');

    return userCredential;
  } catch (error) {
    print("Kakao login failed: $error");
    throw firebase_auth.FirebaseAuthException(
      code: 'ERROR_KAKAO_LOGIN_FAILED',
      message: 'Failed to login with Kakao: $error',
    );
  }
}

Future<firebase_auth.UserCredential> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
        message: 'Missing Google authentication token',
      );
    }

    final String email = googleUser.email;

    // Firestore에서 loginMethod 일치 여부 확인
    isLoginMethodMatching(email, 'Google');

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebase_auth.FirebaseAuth.instance
        .signInWithCredential(credential);
    final firebase_auth.User? user = userCredential.user;

    if (user == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'ERROR_USER_NOT_FOUND',
        message: 'User not found after Google sign-in',
      );
    }

    await addUserToFirestore(user, user.email ?? 'no-email',
        user.displayName ?? 'no-name', 'Google');

    return userCredential;
  } catch (error) {
    print("Google login failed: $error");
    throw firebase_auth.FirebaseAuthException(
      code: 'ERROR_GOOGLE_LOGIN_FAILED',
      message: 'Failed to login with Google: $error',
    );
  }
}

Future<firebase_auth.UserCredential> signInWithApple() async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = firebase_auth.OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken ?? '',
      accessToken: appleCredential.authorizationCode,
    );

    final String email = appleCredential.email ?? '';

    // Firestore에서 loginMethod 일치 여부 확인
    isLoginMethodMatching(email, 'Apple');

    final userCredential = await firebase_auth.FirebaseAuth.instance
        .signInWithCredential(oauthCredential);
    final firebase_auth.User? user = userCredential.user;

    if (user == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'ERROR_USER_NOT_FOUND',
        message: 'User not found after Apple sign-in',
      );
    }

    final String name =
        (appleCredential.givenName ?? '') + (appleCredential.familyName ?? '');

    await addUserToFirestore(user, email, name, 'Apple');

    return userCredential;
  } catch (error) {
    print("Apple login failed: $error");
    throw firebase_auth.FirebaseAuthException(
      code: 'ERROR_APPLE_LOGIN_FAILED',
      message: 'Failed to login with Apple: $error',
    );
  }
}

Future<bool> checkNickname(firebase_auth.User user) async {
  final DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

  if (snapshot.exists && snapshot.data() != null) {
    return snapshot['nickName'] != '';
  }
  return false;
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  void _showLoading(bool show) {
    setState(() {
      _isLoading = show;
    });
  }

  Future<void> _signInWithGoogle() async {
    _showLoading(true);
    try {
      final userCredential = await signInWithGoogle();
      final user = userCredential.user!;
      final hasNickname = await checkNickname(user);
      final bool isMatching =
          await isLoginMethodMatching(userCredential.user?.email, 'Google');

      if (isMatching == true && hasNickname) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePageNavigationBar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NickNamePage()),
        );
      }
    } catch (e) {
      print('Google login error: $e');
    } finally {
      _showLoading(false);
    }
  }

  Future<void> _signInWithKakao() async {
    _showLoading(true);
    try {
      final userCredential = await signInWithKakao();
      final user = userCredential.user!;
      final hasNickname = await checkNickname(user);
      final bool isMatching =
          await isLoginMethodMatching(userCredential.user?.email, 'Kakao');

      if (isMatching == true && hasNickname) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePageNavigationBar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NickNamePage()),
        );
      }
    } catch (e) {
      print('Kakao login error: $e');
    } finally {
      _showLoading(false);
    }
  }

  Future<void> _signInWithApple() async {
    _showLoading(true);
    try {
      final userCredential = await signInWithApple();
      final user = userCredential.user!;
      final hasNickname = await checkNickname(user);
      final bool isMatching =
          await isLoginMethodMatching(userCredential.user?.email, 'Apple');

      if (isMatching == true && hasNickname) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePageNavigationBar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NickNamePage()),
        );
      }
    } catch (e) {
      print('Apple login error: $e');
    } finally {
      _showLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: (211 / 852) * appHeight),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 172,
                    height: 94,
                    child: Image.asset('assets/island.png'),
                  ),
                  SizedBox(height: (50 / 852) * appHeight),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                        side: const BorderSide(width: 1),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    child: Row(
                      children: [
                        const SizedBox(width: 7),
                        Image.asset('assets/google.png', width: 25),
                        const SizedBox(width: 60),
                        Text('구글 계정으로 시작하기',
                            style: regular15.copyWith(
                                color: const Color(0xff635546))),
                      ],
                    ),
                  ),
                  SizedBox(height: (12 / 852) * appHeight),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFAE200),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signInWithKakao,
                    child: Row(
                      children: [
                        Image.asset('assets/kakao.png', height: 23),
                        const SizedBox(
                          width: 53,
                        ),
                        Text('카카오 계정으로 시작하기',
                            style: regular15.copyWith(
                                color: const Color(0xff635546))),
                      ],
                    ),
                  ),
                  SizedBox(height: (12 / 852) * appHeight),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signInWithApple,
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        const Icon(Icons.apple, size: 35, color: Colors.white),
                        const SizedBox(width: 53),
                        Text(
                          'Apple로 로그인',
                          style: regular15.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            height: 0.08,
                            letterSpacing: -0.32,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: (12 / 852) * appHeight),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff919191),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login_with_id');
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 7),
                        SvgPicture.asset(
                          'assets/login.svg',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 55),
                        Text('아이디 비번으로 시작하기',
                            style: regular15.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            SizedBox(height: (51 / 852) * appHeight),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()));
                },
                child: Text(
                  "계정이 따로 없다면?",
                  style: regular15.copyWith(
                    fontWeight: FontWeight.w200,
                    letterSpacing: -0.32,
                    decoration: TextDecoration.underline,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
