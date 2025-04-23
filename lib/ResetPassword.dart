import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPassword extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final Color primaryBlue = Color(0xFF2196F3);
  final Color darkBlue = Color(0xFF1565C0);
  final Color lightBlue = Color(0xFFBBDEFB);

  Future<void> _resetPassword() async {
    String userEmail = email.text.trim();
    FirebaseAuth _auth = FirebaseAuth.instance;

    if (userEmail.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your email to reset password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: darkBlue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: userEmail);

      Fluttertoast.showToast(
        msg: "Password reset email sent. Check your inbox.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error sending password reset email: $e');

      Fluttertoast.showToast(
        msg: "Failed to send password reset email. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Center(
                child: Image.asset(
                  'assets/images/Reset password.png',
                  height: 200,
                  width: 200,
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'MainFont',
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Enter your email and we'll send you instructions to reset your password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: Container(
                  width: 320,
                  child: TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.mail_outline, color: primaryBlue),
                      filled: true,
                      fillColor: lightBlue.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: Container(
                  width: 320,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "SEND RESET LINK",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'MainFont',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 5,
                      shadowColor: primaryBlue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                      color: darkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}