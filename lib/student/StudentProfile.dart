import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_flow/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentProfile extends StatefulWidget {
  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isLoading = true;
  String emailID = '';
  String name = 'Name';
  String department = 'Department';
  String email = 'Email';
  String prnNo = 'PRN Number';
  String Class = 'Class';
  String sem = 'Semester';
  String div = 'Division';
  String rollNo = 'Roll Number';
String profileUrl='';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    fetchDetails();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Fluttertoast.showToast(msg: "Successfully Logout");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ));
    } catch (e) {
      print("Error for logout $e");
    }
  }

  Future<void> fetchDetails() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get current user's email
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      emailID = currentUser.email ?? '';

      // Get user data
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(emailID)
          .get();

      if (!documentSnapshot.exists) {
        throw Exception("User document not found");
      }

      // Extract data
      final data = documentSnapshot.data() as Map<String, dynamic>;
      name = data['name'] ?? 'Name';
      department = data['department'] ?? 'Department';
      email = data['email'] ?? 'Email';
      prnNo = data['PRN'] ?? 'PRN Number';
      Class = data['class'] ?? 'Class';
      sem = data['semester'] ?? 'Semester';
      div = data['division'] ?? 'Division';
      rollNo = data['rollNumber'] ?? 'Roll Number';
      profileUrl=data['profileUrl'] ?? '';
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching student details: $e");
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Failed to load profile data");
    }
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? bgColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'MainFont',
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor ?? Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.blue[700])!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Colors.blue[700],
                    size: 22,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'MainFont1',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define a list of color combinations for profile fields
    final List<Map<String, Color>> colorSchemes = [
      {'icon': Colors.blue[700]!, 'bg': Colors.white},
      {'icon': Colors.teal[600]!, 'bg': Colors.white},
      {'icon': Colors.indigo[600]!, 'bg': Colors.white},
      {'icon': Colors.amber[700]!, 'bg': Colors.white},
      {'icon': Colors.deepPurple[600]!, 'bg': Colors.white},
      {'icon': Colors.red[600]!, 'bg': Colors.white},
      {'icon': Colors.green[600]!, 'bg': Colors.white},
      {'icon': Colors.orange[600]!, 'bg': Colors.white},
    ];

    return Scaffold(
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 50.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.blue[700],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'MainFont',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  titlePadding: EdgeInsets.only(left: 16, bottom: 16),
                  centerTitle: false,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue[800]!, Colors.blue[500]!],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -20,
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      iconSize: 28,
                      onPressed: logout,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blue[700]!,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Container(
                            height: 120,
                            width: 120,
                            child:
                            profileUrl==''||profileUrl.isEmpty?
                            Image.asset(
                              'assets/images/profile.png',
                              fit: BoxFit.cover,
                            )
                                :
                            Image.network(
                              profileUrl,
                              fit: BoxFit.cover,
                            )

                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'MainFont',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ),

                    // Display fields with different color schemes
                    _buildProfileField(
                      label: "Email",
                      value: email,
                      icon: Icons.email_outlined,
                      iconColor: colorSchemes[0]['icon'],
                      bgColor: colorSchemes[0]['bg'],
                    ),
                    _buildProfileField(
                      label: "Department",
                      value: department,
                      icon: Icons.business,
                      iconColor: colorSchemes[1]['icon'],
                      bgColor: colorSchemes[1]['bg'],
                    ),
                    _buildProfileField(
                      label: "PRN Number",
                      value: prnNo,
                      icon: Icons.assignment_ind_outlined,
                      iconColor: colorSchemes[2]['icon'],
                      bgColor: colorSchemes[2]['bg'],
                    ),
                    _buildProfileField(
                      label: "Class",
                      value: Class,
                      icon: Icons.class_outlined,
                      iconColor: colorSchemes[3]['icon'],
                      bgColor: colorSchemes[3]['bg'],
                    ),
                    _buildProfileField(
                      label: "Semester",
                      value: sem,
                      icon: Icons.calendar_today_outlined,
                      iconColor: colorSchemes[4]['icon'],
                      bgColor: colorSchemes[4]['bg'],
                    ),
                    _buildProfileField(
                      label: "Division",
                      value: div,
                      icon: Icons.people_outline,
                      iconColor: colorSchemes[5]['icon'],
                      bgColor: colorSchemes[5]['bg'],
                    ),
                    _buildProfileField(
                      label: "Roll Number",
                      value: rollNo,
                      icon: Icons.format_list_numbered_outlined,
                      iconColor: colorSchemes[6]['icon'],
                      bgColor: colorSchemes[6]['bg'],
                    ),

                    // Add a decorative element at the bottom
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 32),
                        height: 5,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[300]!, Colors.blue[700]!],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}