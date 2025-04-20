import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_flow/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

//This is an addition type of the magnet
class StudentProfile extends StatefulWidget {

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  int _selectedIndex = 0;
  bool textfields=false;
  TextEditingController nameController=TextEditingController();
  TextEditingController departmentController=TextEditingController();
  String emailID='';
String name='Name',department='Department',email='Email',prnNo='PRN Number',Class='Class',sem='Semester',div='Division',rollNo='Roll Number';
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

  void initState(){
    super.initState();
  fetchDetails();

  }
  Future<void> fetchDetails()async{
    try{
      emailID=FirebaseAuth.instance.currentUser!.email!;

    DocumentSnapshot documentSnapshot=await FirebaseFirestore.instance.collection('users').doc(emailID).get();
    name=documentSnapshot.get('name');
    department=documentSnapshot.get('department');
    email=documentSnapshot.get('email');
    prnNo=documentSnapshot.get('PRN');
    Class=documentSnapshot.get('class');
    sem=documentSnapshot.get('semester');
    div=documentSnapshot.get('division');
    rollNo=documentSnapshot.get('rollNumber');
    setState(() {

    });
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   margin: EdgeInsets.only(top: 30,left: 280),
            //   child: IconButton(
            //     icon: Icon(Icons.logout_outlined,
            //       size: 50,),
            //     onPressed: (){
            //       logout();
            //     },
            //   ),
            // ),
            // Container(
            //   margin: EdgeInsets.only(top: 200),
            //   child: Text("StudentProfile",style: TextStyle(fontFamily: "MainFont",fontSize: 20),),
            // )
            Padding(
              padding: const EdgeInsets.only(top: 30,left: 20,right: 20),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Profile",style: TextStyle(fontFamily: 'MainFont',fontSize: 40),),
                     IconButton(icon: Icon(Icons.logout),iconSize: 40,onPressed:  logout)
                  ],
                ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 30),
                height: 100,
                width: 100,
                child: Image.asset('assets/images/profile.png'),
              ),
            ),

//---------------------------------------------------------------------Name-----------------------------------------------
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10,top: 20),
                  child: Text("Name",style: TextStyle(fontSize: 15,fontFamily: 'MainFont'),),
                ),
                // Container(
                //   // decoration: BoxDecoration(
                //   //   borderRadius: BorderRadius.circular(10),
                //   //   border: Border.all(color: Colors.black,width: 2)
                //   // ),
                //   margin: EdgeInsets.only(left: 260,top: 20),
                //   child: Icon(Icons.edit,color: Colors.black,),
                // )
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  enabled: textfields,
                  decoration: InputDecoration(
                    hintText: name,
                    hintStyle: TextStyle(color: Colors.black,fontFamily: 'MainFont1'),
                    prefixIcon: Icon(Icons.account_circle_outlined,color: Colors.black,),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),

                  ),
                ),
              ),
            ),


//---------------------------------------------------------------------Department-----------------------------------------------

            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10,top: 10),
                  child: Text("Department",style: TextStyle(fontSize: 15,fontFamily: 'MainFont'),),
                ),
                // Container(
                //   // decoration: BoxDecoration(
                //   //   borderRadius: BorderRadius.circular(10),
                //   //   border: Border.all(color: Colors.black,width: 2)
                //   // ),
                //   margin: EdgeInsets.only(left: 210,top: 20),
                //   child: Icon(Icons.edit,color: Colors.black,),
                // )
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  enabled: textfields,
                  decoration: InputDecoration(
                    hintText: department,
                    hintStyle: TextStyle(color: Colors.black,fontFamily: 'MainFont1'),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(top: 10, left: 14),
                      child: FaIcon(FontAwesomeIcons.building,color: Colors.black,),
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),

                  ),
                ),
              ),
            ),


//---------------------------------------------------------------------Email-----------------------------------------------
            Container(
              margin: EdgeInsets.only(left: 10, top: 10),
              child: Text(
                "Email",
                style: TextStyle(fontSize: 15, fontFamily: 'MainFont'),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: email,
                    hintStyle: TextStyle(color: Colors.black,fontFamily: 'MainFont1'),
                    prefixIcon: Icon(Icons.email_outlined,color: Colors.black,),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ),

//---------------------------------------------------------------------PRN Number-----------------------------------------------
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10,top: 10),
                  child: Text("PRN Number",style: TextStyle(fontSize: 15,fontFamily: 'MainFont'),),
                ),
                // Container(
                //   // decoration: BoxDecoration(
                //   //   borderRadius: BorderRadius.circular(10),
                //   //   border: Border.all(color: Colors.black,width: 2)
                //   // ),
                //   margin: EdgeInsets.only(left: 210,top: 20),
                //   child: Icon(Icons.edit,color: Colors.black,),
                // )
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  enabled: textfields,
                  decoration: InputDecoration(
                    hintText: prnNo,
                    hintStyle: TextStyle(color: Colors.black,fontFamily: 'MainFont1'),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(top: 10, left: 14),
                      child: FaIcon(FontAwesomeIcons.building,color: Colors.black,),
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),

                  ),
                ),
              ),
            ),

//---------------------------------------------------------------------Class-----------------------------------------------
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10,top: 10),
                  child: Text("Class",style: TextStyle(fontSize: 15,fontFamily: 'MainFont'),),
                ),
                // Container(
                //   // decoration: BoxDecoration(
                //   //   borderRadius: BorderRadius.circular(10),
                //   //   border: Border.all(color: Colors.black,width: 2)
                //   // ),
                //   margin: EdgeInsets.only(left: 210,top: 20),
                //   child: Icon(Icons.edit,color: Colors.black,),
                // )
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  enabled: textfields,
                  decoration: InputDecoration(
                    hintText: Class,
                    hintStyle: TextStyle(color: Colors.black,fontFamily: 'MainFont1'),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(top: 10, left: 14),
                      child: FaIcon(FontAwesomeIcons.building,color: Colors.black,),
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),

                  ),
                ),
              ),
            ),

//---------------------------------------------------------------------Semester-----------------------------------------------
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10,top: 10),
                  child: Text("Semester",style: TextStyle(fontSize: 15,fontFamily: 'MainFont'),),
                ),
                // Container(
                //   // decoration: BoxDecoration(
                //   //   borderRadius: BorderRadius.circular(10),
                //   //   border: Border.all(color: Colors.black,width: 2)
                //   // ),
                //   margin: EdgeInsets.only(left: 210,top: 20),
                //   child: Icon(Icons.edit,color: Colors.black,),
                // )
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  enabled: textfields,
                  decoration: InputDecoration(
                    hintText: sem,
                    hintStyle: TextStyle(color: Colors.black,fontFamily: 'MainFont1'),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(top: 10, left: 14),
                      child: FaIcon(FontAwesomeIcons.building,color: Colors.black,),
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),

                  ),
                ),
              ),
            ),

//---------------------------------------------------------------------Division-----------------------------------------------
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10,top: 10),
                  child: Text("Division",style: TextStyle(fontSize: 15,fontFamily: 'MainFont'),),
                ),
                // Container(
                //   // decoration: BoxDecoration(
                //   //   borderRadius: BorderRadius.circular(10),
                //   //   border: Border.all(color: Colors.black,width: 2)
                //   // ),
                //   margin: EdgeInsets.only(left: 210,top: 20),
                //   child: Icon(Icons.edit,color: Colors.black,),
                // )
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  enabled: textfields,
                  decoration: InputDecoration(
                    hintText: div,
                    hintStyle: TextStyle(color: Colors.black,fontFamily: 'MainFont1'),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(top: 10, left: 14),
                      child: FaIcon(FontAwesomeIcons.building,color: Colors.black,),
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),

                  ),
                ),
              ),
            ),


//---------------------------------------------------------------------Roll Number-----------------------------------------------
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10,top: 10),
                  child: Text("Roll Number",style: TextStyle(fontSize: 15,fontFamily: 'MainFont'),),
                ),
                // Container(
                //   // decoration: BoxDecoration(
                //   //   borderRadius: BorderRadius.circular(10),
                //   //   border: Border.all(color: Colors.black,width: 2)
                //   // ),
                //   margin: EdgeInsets.only(left: 210,top: 20),
                //   child: Icon(Icons.edit,color: Colors.black,),
                // )
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  enabled: textfields,
                  decoration: InputDecoration(
                    hintText: rollNo,
                    hintStyle: TextStyle(color: Colors.black,fontFamily: 'MainFont1'),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(top: 10, left: 14),
                      child: FaIcon(FontAwesomeIcons.building,color: Colors.black,),
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15)),

                  ),
                ),
              ),
            ),

//---------------------------------------------------------------------Logout-----------------------------------------------
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 8.0,right: 8.0),
//                 child: Container(
//                   width: 150,
//                   margin: EdgeInsets.only(top: 40,bottom: 20),
//                   child: ElevatedButton(
//                     child: Text(
//                       textfields?"Save":
//                       "Edit Profile",
//                       style: TextStyle(color: Colors.white, fontFamily: 'MainFont'),
//                     ),
//                     onPressed: (){
//                       if(textfields) {
//                         if(nameController.text.isNotEmpty && departmentController.text.isNotEmpty){
//
//                           FirebaseFirestore.instance.collection('users').doc(emailID).update({
//                             'name':nameController.text.toString(),
//                             'department':departmentController.text.toString()
//                           });
//                         }
//                         else if(nameController.text.isNotEmpty) {
//                           FirebaseFirestore.instance.collection('users').doc(emailID).update({
//                             'name':nameController.text.toString()
//                             // 'department':departmentController.text.toString()
//                           });
//                         }else if(departmentController.text.isNotEmpty) {
//                           FirebaseFirestore.instance.collection('users').doc(emailID).update({
//                             // 'name':nameController.text.toString()
//                             'department':departmentController.text.toString()
//                           });
//                         }
//                         Fluttertoast.showToast(msg: "Information updated Successfully");
//                       }
//                       setState(() {
//                         textfields=!textfields;
//                       });
//                     },
//                     // onPressed: (){},
//                     style: ButtonStyle(
//                       // elevation: MaterialStateProperty.resolveWith((states) => 5),
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(80.0),
//                         ),
//                       ),
//                       backgroundColor:
//                       MaterialStateColor.resolveWith((states) => Colors.black),
//                     ),
//                   ),
//                 ),
//               ),
//             ),


          ],
        ),
      ),
    );
  }
}
