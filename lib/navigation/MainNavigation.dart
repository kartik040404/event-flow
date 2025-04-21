import 'package:event_flow/EventsScreen.dart';
import 'package:event_flow/ProfileScreen.dart';
import 'package:event_flow/faculty/FacultyEvent.dart';
import 'package:event_flow/faculty/FacultyHome.dart';
import 'package:event_flow/faculty/FacultyProfile.dart';
import 'package:event_flow/student/StudentEvent.dart';
import 'package:event_flow/student/StudentProfile.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../admin/AdminHome.dart';
import '../student/StudentHome.dart';
import 'UserRole.dart';


class MainNavigation extends StatefulWidget {
  final UserRole role;

  const MainNavigation({required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  List<Widget> get _pages {
    switch (widget.role) {
      case UserRole.student:
        return [StudentHome(), StudentEvent(), StudentProfile()];
      case UserRole.faculty:
        return [FacultyHome(), FacultyEvent(), FacultyProfile()];
      case UserRole.admin:
        return [AdminHome(), Eventsscreen(), Profilescreen()];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))],
    ),
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
    child: GNav(
    gap: 8,
    activeColor: Colors.white,
    color: Colors.grey[800],
    iconSize: 24,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    duration: Duration(milliseconds: 400),
    tabBackgroundColor: Colors.black,
    // tabBackgroundGradient: LinearGradient(
    // colors: [
    // Colors.white,
    // Colors.black,
    // ],
      // begin: Alignment.centerLeft,
      // end: Alignment.centerRight,
      //   stops: [0.0,1], // even more subtle white

    // ),
    tabs: [
    GButton(icon: Icons.home, text: 'Home'),
    GButton(icon: Icons.event, text: 'Events'),
    GButton(icon: Icons.person, text: 'Profile'),
    ],
    selectedIndex: _selectedIndex,
    onTabChange: (index) {
    setState(() => _selectedIndex = index);
    },
    ),
    ),
    ),
    );
    }
}
