import 'package:flutter/material.dart';
import 'package:kavir_face/package.dart';
import 'package:kavir_face/screens/music/music_screen.dart';
import 'package:kavir_face/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = [
    const MusicScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: _bottomNavigationBarItems(),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> _bottomNavigationBarItems() {
    return [
      _buildBottomNavigationItem(
        icon: const Icon(Icons.music_note),
        label: StringConstant.textMusic,
      ),
      _buildBottomNavigationItem(
        icon: const Icon(Icons.person),
        label: StringConstant.textProfile,
      ),
    ];
  }

  BottomNavigationBarItem _buildBottomNavigationItem({
    required Icon icon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: icon,
      label: label,
    );
  }

  Widget buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: _widgetOptions,
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(StringConstant.appName),
      centerTitle: true,
    );
  }
}
