import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:ssoup_new/about_home/private.dart';
import 'package:ssoup_new/about_home/service.dart';
import 'package:ssoup_new/about_home/setting_page.dart';
import 'package:ssoup_new/about_login/login_with_id.dart';
import 'package:ssoup_new/constants.dart';
import 'package:ssoup_new/about_home/home.dart';
import 'package:ssoup_new/about_home/home_navigationbar.dart';
import 'package:ssoup_new/plogging/plogging.dart';
import 'package:ssoup_new/about_login/login.dart';
import 'package:ssoup_new/nick_name.dart';
import 'package:ssoup_new/transport/taxi_page.dart';
import 'splash.dart';
import 'transport/boat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  KakaoSdk.init(
    nativeAppKey: kakaoNativeAppKey,
    javaScriptAppKey: kakaoJavaScriptAppKey,
  );

  /*runApp(
      const MaterialApp(debugShowCheckedModeBanner: false, home: SplashPage()));

  await Future.delayed(const Duration(seconds: 3));*/

  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/nick_name_page": (BuildContext context) => const NickNamePage(),
        "/home_page": (BuildContext context) => const HomePage(),
        "/home_page_navigationBar": (BuildContext context) =>
            const HomePageNavigationBar(),
        "/setting_page": (BuildContext context) => const SettingsPage(),
        "/plogging_page": (BuildContext context) => const PloggingPage(),
        "/login_with_id": (BuildContext context) => const LoginWithId(),
        "/taxi_page": (BuildContext context) => const TaxiPage(),
        "/boat_page": (BuildContext context) => const BoatPage(),
        "/splash": (BuildContext context) => const SplashPage(),
        "/private": (BuildContext context) => const PrivatePage(),
        "/service": (BuildContext context) => const ServicePage(),
        "/login_page": (BuildContext context) => const LoginPage(),
      },
      home: const LoginPage(),
    );
  }
}
