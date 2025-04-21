import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_flow/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class FacultyProfile extends StatefulWidget {
  @override
  State<FacultyProfile> createState() => _FacultyProfileState();
}

class _FacultyProfileState extends State<FacultyProfile> {
  int _selectedIndex = 0;
  String id = "";
  String name = 'Name';
  String department = 'Department';
  String email = 'Email';
  String designation = 'Designation';
  String qualification = 'Qualification';
  String specialization = 'Specialization';
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    fetchDetails();
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

      email = currentUser.email ?? '';

      // Query the users collection by email
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (!documentSnapshot.exists) {
        throw Exception("User document not found");
      }

      // DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      id = documentSnapshot.id;

      // Extract all the needed fields
      final data = documentSnapshot.data() as Map<String, dynamic>;
      name = data['name'] ?? 'Name';
      department = data['department'] ?? 'Department';
      designation = data['designation'] ?? 'Designation';
      qualification = data['qualification'] ?? 'Qualification';
      specialization = data['specialization'] ?? 'Specialization';

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      print("Error fetching faculty details: $e");
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, top: 10),
          child: Text(
            label,
            style: TextStyle(fontSize: 15, fontFamily: 'MainFont'),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'MainFont1',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile",
                    style: TextStyle(fontFamily: 'MainFont', fontSize: 32),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout),
                    iconSize: 32,
                    onPressed: logout,
                  )
                ],
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Display name
            _buildProfileField(
              label: "Name",
              value: name,
              icon: Icons.person,
            ),

            // Display email
            _buildProfileField(
              label: "Email",
              value: email,
              icon: Icons.email_outlined,
            ),

            // Display department
            _buildProfileField(
              label: "Department",
              value: department,
              icon: Icons.business,
            ),

            // Display designation
            _buildProfileField(
              label: "Designation",
              value: designation,
              icon: Icons.work_outline,
            ),

            // Display qualification
            _buildProfileField(
              label: "Qualification",
              value: qualification,
              icon: Icons.school_outlined,
            ),

            // Display specialization
            _buildProfileField(
              label: "Specialization",
              value: specialization,
              icon: Icons.emoji_objects_outlined,
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
     );
  }
}