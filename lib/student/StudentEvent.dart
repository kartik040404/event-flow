import 'package:event_flow/student/StudentEventDetails.dart';
import 'package:event_flow/student/StudentParticipated.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ProgramDetails {
  final String programDetails;
  final String date;
  final String time;
  final String id;
  ProgramDetails({
    required this.programDetails,
    required this.date,
    required this.time,
    required this.id,
  });

  factory ProgramDetails.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProgramDetails(
      programDetails: data['programDetails'] ?? '',
      date: data['startDate'] ?? '',
      time: data['startTime'] ?? '',
      id: doc.id,
    );
  }
}

Future<List<ProgramDetails>> fetchProgramDetails() async {
  try {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('events')
        // .where('permission', isEqualTo: 'approved')
        .get();

    List<ProgramDetails> programList = querySnapshot.docs
        .map((DocumentSnapshot doc) => ProgramDetails.fromFirestore(doc))
        .toList();

    return programList;
  } catch (e) {
    // Handle error
    print('Error fetching program details: $e');
    return [];
  }
}

class StudentEvent extends StatefulWidget {
  @override
  _StudentEventState createState() => _StudentEventState();
}
final FirebaseAuth _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;

class _StudentEventState extends State<StudentEvent> {
  int _selectedIndex = 0;
  late int faculty;
  late String emailID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 30),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                constraints: BoxConstraints.expand(height: 50),
                child: TabBar(
                  overlayColor: MaterialStateProperty.resolveWith((states) => Colors.grey.shade300),
                  indicatorColor: Colors.black,
                  dividerColor: MaterialStateColor.resolveWith(
                        (states) => Colors.black,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: Text(
                        "Events",
                        style: TextStyle(
                          fontFamily: "MainFont",
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Your Activities",
                        style: TextStyle(
                          fontFamily: "MainFont",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [


                    // First Tab: StudentEvent-------------------------------------------------------------------------------
                    FutureBuilder<List<ProgramDetails>>(
                      future: fetchProgramDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: Colors.black,));
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        List<ProgramDetails> programList = snapshot.data ?? [];

                        programList.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

                        return ListView.builder(
                          itemBuilder: (context, index) {
                            ProgramDetails programDetails = programList[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentEventDetails(eventId: programDetails.id),));
                              },
                              child:
                              Card(
                                // elevation: 2,
                                shadowColor: Colors.black,
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        "Event : ${programDetails.programDetails}",
                                        style: TextStyle(fontFamily: "MainFont"),
                                      ),
                                      margin: EdgeInsets.only(left: 10, top: 10),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                          child: Text(
                                            getDate(programDetails.date),
                                            style: TextStyle(fontFamily: "MainFont1"),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                                              child: Text(
                                                "Time : ${programDetails.time}",
                                                style: TextStyle(fontFamily: "MainFont1"),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: programList.length,
                        );
                      },
                    ),

                    // Second Tab: Your Activities--------------------------------------------------------------------------
                    FutureBuilder<List<ProgramDetails>>(

                      future: fetchUserActivities(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        List<ProgramDetails> userActivities = snapshot.data ?? [];

                        return ListView.builder(
                          itemBuilder: (context, index) {
                            ProgramDetails userActivity = userActivities[index];

                            return
                              InkWell(
                                onTap: (){
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => StudentEventDetails(eventId: userActivity.id),));
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => StudentParticipated(eventId: userActivity.id, email: user!.email),));
                                },
                                child: Card(
                                  shadowColor: Colors.black,
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          "Event : ${userActivity.programDetails}",
                                          style: TextStyle(fontFamily: "MainFont"),
                                        ),
                                        margin: EdgeInsets.only(left: 10, top: 10),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                            child: Text(
                                              getDate(userActivity.date),
                                              style: TextStyle(fontFamily: "MainFont1"),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                                                child: Text(
                                                  "Time : ${userActivity.time}",
                                                  style: TextStyle(fontFamily: "MainFont1"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                          },
                          itemCount: userActivities.length,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()=>{},
        // onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => StudentEventsHistory(),)),
        label: const Text('History',style: TextStyle(fontFamily: 'MainFont',color: Colors.white),),
        backgroundColor: Colors.black,
      ),
    );
  }

  String getDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    DateTime currentDate = DateTime.now();

    if (isSameDay(parsedDate, currentDate)) {
      return "Today";
    } else if (isSameDay(parsedDate, currentDate.add(Duration(days: 1)))) {
      return "Tomorrow";
    }
    return "Date : ${date}";
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Future<List<ProgramDetails>> fetchUserActivities() async {
    try {
      // Replace 'user@example.com' with the actual user's email
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get();

      if (userQuery.docs.isNotEmpty) {

        DocumentSnapshot userDoc = userQuery.docs.first;
        List<dynamic> activityIds = userDoc['activities'] ?? [];
        List<ProgramDetails> userActivities = await fetchProgramDetailsByIds(activityIds);
        return userActivities;

      } else {
        print('User not found');
        return [];
      }
    } catch (e) {
      print('Error fetching user activities: $e');
      return [];
    }
  }


  Future<List<ProgramDetails>> fetchProgramDetailsByIds(List<dynamic> activityIds) async {
    try {
      List<ProgramDetails> programList = [];

      // We cannot use 'whereIn' with document IDs directly in a collection query,
      // so we'll fetch documents one by one using their IDs
      for (String docId in activityIds) {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(docId)
            .get();

        if (docSnapshot.exists) {
          ProgramDetails program = ProgramDetails.fromFirestore(docSnapshot);
          programList.add(program);
        }
      }

      return programList;
    } catch (e) {
      print('Error fetching program details by IDs: $e');
      return [];
    }
  }

  // Future<List<ProgramDetails>> fetchProgramDetailsByIds(List<dynamic> activityIds) async {
  //   try {
  //     QuerySnapshot programQuery = await FirebaseFirestore.instance
  //         .collection('events')
  //         .where('programDetails', whereIn: activityIds)
  //         .get();
  //
  //     List<ProgramDetails> programList = programQuery.docs
  //         .map((DocumentSnapshot doc) => ProgramDetails.fromFirestore(doc))
  //         .toList();
  //
  //     return programList;
  //   } catch (e) {
  //     print('Error fetching program details by IDs: $e');
  //     return [];
  //   }
  // }
}

void main() {
  runApp(
    MaterialApp(
      home: StudentEvent(),
    ),
  );
}
