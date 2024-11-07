import 'package:flutter/material.dart';
import 'package:bitcoin_icons/bitcoin_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/et.dart';
import 'package:ssoup_new/about_map/bigmap.dart';
import 'package:ssoup_new/about_home/home.dart';
import 'package:ssoup_new/stamp.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../transport/transport_page.dart';

class HomePageNavigationBar extends StatefulWidget {
  const HomePageNavigationBar({super.key});

  @override
  State<HomePageNavigationBar> createState() => _HomePageNavigationBarState();
}

class _HomePageNavigationBarState extends State<HomePageNavigationBar> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    currentPageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              blurRadius: 4,
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (Set<WidgetState> states) {
                final isSelected = states.contains(WidgetState.selected);
                return TextStyle(
                  color: isSelected
                      ? const Color(0xff1a86ff)
                      : const Color(0xFF9D9D9D),
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -0.32,
                );
              },
            ),
          ),
          child: NavigationBar(
            indicatorColor: Colors.transparent,
            backgroundColor: Colors.white,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            destinations: <Widget>[
              const NavigationDestination(
                selectedIcon: Icon(BitcoinIcons.home_outline,
                    color: Color(0xff1a86ff), size: 31),
                icon: Icon(
                  BitcoinIcons.home_outline,
                  size: 31,
                  color: Color(0xff9d9d9d),
                ),
                label: '홈',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  'assets/fluent-stamp-32-light.svg',
                  width: 31,
                  height: 31,
                  color: const Color(0xff9d9d9d),
                ),
                selectedIcon: SvgPicture.asset(
                  'assets/fluent-stamp-32-light.svg',
                  width: 31,
                  height: 31,
                  color: const Color(0xff1a86ff),
                ),
                label: '스탬프',
              ),
              const NavigationDestination(
                icon: Iconify(
                  Et.map,
                  size: 31,
                  color: Color(0xff9d9d9d),
                ),
                selectedIcon: Iconify(
                  Et.map,
                  size: 31,
                  color: Color(0xff1a86ff),
                ),
                label: '지도',
              ),
              const NavigationDestination(
                icon: Iconify(
                  Ph.taxi_thin,
                  size: 31,
                  color: Color(0xff9d9d9d),
                ),
                selectedIcon: Iconify(
                  Ph.taxi_thin,
                  size: 31,
                  color: Color(0xff1a86ff),
                ),
                label: '이동수단',
              ),
            ],
          ),
        ),
      ),
      body: <Widget>[
        const HomePage(),
        const StampPage(),
        const BigMapPage(),
        const TransportationPage(),
      ][currentPageIndex],
    );
  }
}
