import 'package:flutter/material.dart';

import 'theme/text.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: (193 / 393) * screenWidth,
              height: (121 / 852) * screenHeight,
              child: Image.asset('assets/logo.png'),
            ),
            const SizedBox(height: 47),
            Text('울릉도의 다양한 관광코스와 플로깅까지 즐길 수 있는',
                style: regular13.copyWith(color: Colors.black)),
            Text('울릉도 관광객만을 위한 서비스',
                style: regular13.copyWith(color: Colors.black)),
            const SizedBox(height: 4),
            Opacity(
              opacity: 0.85,
              child: Container(
                width: (394 / 393) * screenWidth,
                height: (365 / 852) * screenHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/ul.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
