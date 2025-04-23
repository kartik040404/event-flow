import 'package:event_flow/EventsScreen.dart';
import 'package:event_flow/ProfileScreen.dart';
import 'package:event_flow/admin/AdminEvent.dart';
import 'package:event_flow/admin/AdminProfile.dart';
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
        return [AdminHome(), AdminEvent(), AdminProfile()];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, -3),
              spreadRadius: 1,
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            color: Colors.blue[800],
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutExpo,
            tabBackgroundGradient: LinearGradient(
              colors: [
                Colors.blue.shade700,
                Colors.lightBlue.shade200,
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),

            tabBorderRadius: 30,
            rippleColor: Colors.blue[300]!,
            hoverColor: Colors.blue[100]!,
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                iconColor: Colors.blue[600],
                iconActiveColor: Colors.white,
                textColor: Colors.white,
                iconSize: 24,
              ),
              GButton(
                icon: Icons.event,
                text: 'Events',
                iconColor: Colors.blue[600],
                iconActiveColor: Colors.white,
                textColor: Colors.white,
                iconSize: 24,
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                iconColor: Colors.blue[600],
                iconActiveColor: Colors.white,
                textColor: Colors.white,
                iconSize: 24,
              ),
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