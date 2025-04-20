import 'package:event_flow/navigation/MainNavigation.dart';
import 'package:event_flow/navigation/UserRole.dart';
import 'package:event_flow/student/StudentHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

import 'admin/AdminHome.dart';
import 'faculty/FacultyHome.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      // User is already logged in, determine their role and navigate accordingly
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          _determineUserRoleAndNavigate(user.email!);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Attempt to sign in with email and password
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Check if user exists and has a role
        if (userCredential.user != null) {
          // Save login state
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', _emailController.text.trim());

          // Determine role and navigate to appropriate screen
          _determineUserRoleAndNavigate(_emailController.text.trim());
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          if (e.code == 'user-not-found') {
            _errorMessage = 'User not found. Please check your email.';
          } else if (e.code == 'wrong-password') {
            _errorMessage = 'Incorrect password. Please try again.';
          } else {
            _errorMessage = 'Login failed: ${e.message}';
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: $e';
        });
      }
    }
  }

  Future<void> _determineUserRoleAndNavigate(String email) async {
    try {
      // Get user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        int role = userData['role'] ?? 3; // Default to club member if not specified

        // Navigate based on role
        switch (role) {
          case 0:
          // Student
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainNavigation(role: UserRole.student)),
            );
            break;
          case 1:
          // Faculty
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainNavigation(role: UserRole.faculty)),
            );
            break;
          case 2:
          // Admin
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainNavigation(role: UserRole.admin)),
            );
            break;
          default:
          // Club member or other
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainNavigation(role: UserRole.faculty)),
            );
            break;
        }
      } else {
        // User document doesn't exist in Firestore
        setState(() {
          _isLoading = false;
          _errorMessage = 'User profile not found in database.';
        });

        // Sign out the user since their profile isn't complete
        await FirebaseAuth.instance.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('userEmail');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error determining user role: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SizedBox(
              //   height: 150,
              //   child: Lottie.asset(
              //     'assets/lottie/login-animation.json',
              //     fit: BoxFit.contain,
              //   ),
              // ),
              const SizedBox(height: 40),
              const Text(
                'Seminar Hall Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'College Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.red.withOpacity(0.1),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Implement forgot password functionality
                  // This can open a dialog or navigate to a password reset screen
                },
                child: const Text('Forgot Password?'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Use your college credentials to login',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Update your SplashScreen's initState to navigate to LoginScreen
/*
void initState() {
  super.initState();

  // Navigate to login screen after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  });
}
*/