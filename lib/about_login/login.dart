// 필요한 패키지들을 import 합니다.
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../theme/text.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 로그인 정보를 안전하게 저장하기 위한 패키지
import 'register_page.dart'; // RegisterPage를 import 합니다.

// 로그인 방법이 일치하는지 확인하는 함수입니다.
Future<bool> isLoginMethodMatching(String? email, String loginMethod) async {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('user');
  final QuerySnapshot result =
      await users.where('email', isEqualTo: email).get();

  if (result.docs.isNotEmpty) {
    final userData = result.docs.first.data() as Map<String, dynamic>;
    return userData['loginMethod'] == loginMethod;
  }

  return false;
}

// Firestore에 사용자 정보를 추가하거나 업데이트하는 함수입니다.
Future<void> addUserToFirestore(firebase_auth.User user, String email,
    String name, String loginMethod) async {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('user');
  final DocumentSnapshot snapshot = await users.doc(user.uid).get();

  if (snapshot.exists) {
    // 사용자 정보가 이미 존재하면 업데이트합니다.
    final updatedUserData = {
      'email': email,
      'name': name,
      'loginMethod': loginMethod,
    };
    await users.doc(user.uid).update(updatedUserData);
    print('User data updated in Firestore: $updatedUserData');
  } else {
    // 새로운 사용자 정보를 추가합니다.
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

// 카카오로 로그인하는 함수입니다.
Future<firebase_auth.UserCredential> signInWithKakao() async {
  try {
    // 카카오 계정으로 로그인합니다.
    final kakao.OAuthToken token =
        await kakao.UserApi.instance.loginWithKakaoAccount();
    print('Kakao login successful: ${token.accessToken}');

    // 카카오 사용자 정보를 가져옵니다.
    final kakao.User kakaoUser = await kakao.UserApi.instance.me();
    print("email: ${kakaoUser.kakaoAccount?.email}");
    final email = kakaoUser.kakaoAccount?.email ?? '';
    final name = kakaoUser.kakaoAccount?.profile?.nickname ?? '';

    // 로그인 방법이 일치하는지 확인합니다.
    await isLoginMethodMatching(email, 'Kakao');

    // Firebase 인증 정보를 생성합니다.
    final credential = firebase_auth.OAuthProvider("oidc.kakao.com").credential(
      accessToken: token.accessToken,
      idToken: token.idToken ?? '',
    );

    // Firebase에 로그인합니다.
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

// 구글로 로그인하는 함수입니다.
Future<firebase_auth.UserCredential> signInWithGoogle() async {
  try {
    // 구글 로그인 창을 띄웁니다.
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    // 구글 인증 정보를 가져옵니다.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
        message: 'Missing Google authentication token',
      );
    }

    final String email = googleUser.email;

    // 로그인 방법이 일치하는지 확인합니다.
    await isLoginMethodMatching(email, 'Google');

    // Firebase 인증 정보를 생성합니다.
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase에 로그인합니다.
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

// 애플로 로그인하는 함수입니다.
Future<firebase_auth.UserCredential> signInWithApple() async {
  try {
    // 애플 로그인 창을 띄웁니다.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // Firebase 인증 정보를 생성합니다.
    final oauthCredential = firebase_auth.OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken ?? '',
      accessToken: appleCredential.authorizationCode,
    );

    final String email = appleCredential.email ?? '';

    // 로그인 방법이 일치하는지 확인합니다.
    await isLoginMethodMatching(email, 'Apple');

    // Firebase에 로그인합니다.
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

// 닉네임이 설정되어 있는지 확인하는 함수입니다.
Future<bool> checkNickname(firebase_auth.User user) async {
  final DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

  if (snapshot.exists && snapshot.data() != null) {
    return snapshot['nickName'] != '';
  }
  return false;
}

// 로그인 페이지의 StatefulWidget입니다.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

// 로그인 페이지의 상태를 관리하는 클래스입니다.
class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false; // 로딩 상태를 관리합니다.

  final storage = FlutterSecureStorage(); // FlutterSecureStorage 인스턴스 생성
  dynamic userInfo = ''; // storage에 있는 유저 정보를 저장할 변수

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 로그인 상태를 확인합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  // 로딩 상태를 표시하거나 숨기는 함수입니다.
  void _showLoading(bool show) {
    setState(() {
      _isLoading = show;
    });
  }

  // 로그인 성공 시 사용자 정보를 저장하는 함수입니다.
  Future<void> saveUserInfo(String loginMethod) async {
    await storage.write(key: 'login_success', value: loginMethod);
  }

  // 현재 로그인 상태를 확인하는 함수입니다.
  Future<void> _checkLoginStatus() async {
    // 저장된 로그인 정보를 읽어옵니다.
    userInfo = await storage.read(key: 'login_success');

    // userInfo가 null이 아니면 자동 로그인합니다.
    if (userInfo != null) {
      Navigator.pushReplacementNamed(context, '/home_page_navigationBar');
    } else {
      print('로그인이 필요합니다');
    }
  }

  // 구글 로그인 버튼을 눌렀을 때 실행되는 함수입니다.
  Future<void> _signInWithGoogle() async {
    _showLoading(true);
    try {
      final userCredential = await signInWithGoogle();
      final user = userCredential.user!;
      final hasNickname = await checkNickname(user);
      final bool isMatching = await isLoginMethodMatching(user.email, 'Google');

      if (isMatching && hasNickname) {
        // 로그인 성공 시 사용자 정보를 저장합니다.
        await saveUserInfo('Google');
        Navigator.pushReplacementNamed(context, "/home_page_navigationBar");
      } else {
        Navigator.pushNamed(context, "/nick_name_page");
      }
    } catch (e) {
      print('Google login error: $e');
    } finally {
      _showLoading(false);
    }
  }

  // 카카오 로그인 버튼을 눌렀을 때 실행되는 함수입니다.
  Future<void> _signInWithKakao() async {
    _showLoading(true);
    try {
      final userCredential = await signInWithKakao();
      final kakao.User kakaoUser = await kakao.UserApi.instance.me();
      final email = kakaoUser.kakaoAccount?.email ?? '';

      final user = userCredential.user!;
      final hasNickname = await checkNickname(user);
      final bool isMatching = await isLoginMethodMatching(email, 'Kakao');

      if (isMatching && hasNickname) {
        // 로그인 성공 시 사용자 정보를 저장합니다.
        await saveUserInfo('Kakao');
        Navigator.pushReplacementNamed(context, "/home_page_navigationBar");
      } else {
        Navigator.pushNamed(context, "/nick_name_page");
      }
    } catch (e) {
      print('Kakao login error: $e');
    } finally {
      _showLoading(false);
    }
  }

  // 애플 로그인 버튼을 눌렀을 때 실행되는 함수입니다.
  Future<void> _signInWithApple() async {
    _showLoading(true);
    try {
      final userCredential = await signInWithApple();
      final user = userCredential.user!;
      final hasNickname = await checkNickname(user);
      final bool isMatching = await isLoginMethodMatching(user.email, 'Apple');

      if (isMatching && hasNickname) {
        // 로그인 성공 시 사용자 정보를 저장합니다.
        await saveUserInfo('Apple');
        Navigator.pushReplacementNamed(context, "/home_page_navigationBar");
      } else {
        Navigator.pushNamed(context, "/nick_name_page");
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
    double appWidth = MediaQuery.of(context).size.width;

    // 로그인 버튼을 생성하는 위젯입니다.
    Widget loginButton(
      String loginImage,
      int colorValue,
      String loginMessage,
    ) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(colorValue),
          elevation: 0,
          minimumSize: Size(double.infinity, (50 / 852) * appHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((3 / 393) * appWidth),
            side: (loginImage == "google")
                ? const BorderSide()
                : const BorderSide(color: Colors.white),
          ),
        ),
        onPressed: () {
          if (loginImage == "google") {
            _signInWithGoogle();
          } else if (loginImage == "kakao") {
            _signInWithKakao();
          } else if (loginImage == "login") {
            Navigator.pushNamed(context, "/login_with_id");
          } else {
            _signInWithApple();
          }
        },
        child: Row(
          children: [
            Image.asset(
              'assets/$loginImage.png',
              height: (35 / 852) * appHeight,
              width: (35 / 393) * appWidth,
            ),
            SizedBox(width: (53 / 393) * appWidth),
            Text(
              loginMessage,
              style: regular15.copyWith(
                color: (loginImage == "login")
                    ? const Color(0xffffffff)
                    : const Color(0xff635546),
                fontSize: (15 / 393) * appWidth,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: (211 / 852) * appHeight),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: (24.0 / 393) * appWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: (172 / 393) * appWidth,
                        height: (94 / 852) * appHeight,
                        child: Image.asset('assets/island.png'),
                      ),
                      SizedBox(height: (50 / 852) * appHeight),
                      loginButton("google", 0xffFFFFFF, "구글 계정으로 시작하기"),
                      SizedBox(height: (12 / 852) * appHeight),
                      loginButton("kakao", 0xffFAE200, "카카오 계정으로 시작하기"),
                      SizedBox(height: (12 / 852) * appHeight),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          elevation: 0,
                          minimumSize:
                              Size(double.infinity, (50 / 852) * appHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular((3 / 393) * appWidth),
                          ),
                        ),
                        onPressed: _isLoading ? null : _signInWithApple,
                        child: Row(
                          children: [
                            Icon(Icons.apple,
                                size: (35 / 393) * appWidth,
                                color: Colors.white),
                            SizedBox(width: (53 / 393) * appWidth),
                            Text(
                              'Apple로 로그인',
                              style: regular15.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                                height: 0.08,
                                letterSpacing: -0.32,
                                fontSize: (16 / 393) * appWidth,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: (12 / 852) * appHeight),
                      loginButton("login", 0xff919191, "아이디 비번으로 시작하기"),
                      SizedBox(height: (12 / 852) * appHeight),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 70, 69, 69),
                          elevation: 0,
                          minimumSize:
                              Size(double.infinity, (50 / 852) * appHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular((3 / 393) * appWidth),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, "/home_page_navigationBar");
                        },
                        child: Text(
                          '게스트 모드로 시작하기',
                          style: regular15.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            height: 0.08,
                            letterSpacing: -0.32,
                            fontSize: (16 / 393) * appWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (31 / 852) * appHeight),
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
                      fontSize: (15 / 393) * appWidth,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/service");
                      },
                      child: Text(
                        "이용약관",
                        style: regular15.copyWith(
                          fontWeight: FontWeight.w200,
                          letterSpacing: -0.32,
                          fontSize: (15 / 393) * appWidth,
                          color: const Color.fromRGBO(0, 0, 0, 0.5),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/private");
                      },
                      child: Text(
                        "개인정보 처리방침",
                        style: regular15.copyWith(
                            fontWeight: FontWeight.w200,
                            letterSpacing: -0.32,
                            fontSize: (15 / 393) * appWidth,
                            color: const Color.fromRGBO(0, 0, 0, 0.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 로딩 중일 때 로딩 인디케이터를 표시합니다.
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
