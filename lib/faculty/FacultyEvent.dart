// import 'package:event_flow/student/FacultyEventDetails.dart';
import 'package:event_flow/faculty/FacultyEventDetailsFilling.dart';
import 'package:event_flow/faculty/FacultyEventFullDetails.dart';
import 'package:event_flow/student/StudentParticipated.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'FacultyEventDetails.dart';

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
    .where('permission', isEqualTo: 'approved')
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

enum SortOption {
  dateAscending,
  dateDescending,
  titleAZ,
  titleZA,
}

class FacultyEvent extends StatefulWidget {
  @override
  _FacultyEventState createState() => _FacultyEventState();
}
final FirebaseAuth _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;

class _FacultyEventState extends State<FacultyEvent> {
  int _selectedIndex = 0;
  late int faculty;
  late String emailID;
  SortOption _currentSortOption = SortOption.dateAscending;

  void _sortPrograms(List<ProgramDetails> programs) {
    switch (_currentSortOption) {
      case SortOption.dateAscending:
        programs.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
        break;
      case SortOption.dateDescending:
        programs.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
        break;
      case SortOption.titleAZ:
        programs.sort((a, b) => a.programDetails.toLowerCase().compareTo(b.programDetails.toLowerCase()));
        break;
      case SortOption.titleZA:
        programs.sort((a, b) => b.programDetails.toLowerCase().compareTo(a.programDetails.toLowerCase()));
        break;
    }
  }

  String _getSortOptionText() {
    switch (_currentSortOption) {
      case SortOption.dateAscending:
        return 'Date: Oldest First';
      case SortOption.dateDescending:
        return 'Date: Newest First';
      case SortOption.titleAZ:
        return 'Title: A-Z';
      case SortOption.titleZA:
        return 'Title: Z-A';
    }
  }

  Widget _buildSortFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              fontFamily: 'MainFont',
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () {
                _showSortOptions();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getSortOptionText(),
                      style: TextStyle(
                        fontFamily: 'MainFont1',
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  'Sort Events',
                  style: TextStyle(
                    fontFamily: 'MainFont',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              _buildSortOption(
                title: 'Date: Oldest First',
                icon: Icons.arrow_upward,
                option: SortOption.dateAscending,
              ),
              _buildSortOption(
                title: 'Date: Newest First',
                icon: Icons.arrow_downward,
                option: SortOption.dateDescending,
              ),
              _buildSortOption(
                title: 'Title: A-Z',
                icon: Icons.sort_by_alpha,
                option: SortOption.titleAZ,
              ),
              _buildSortOption(
                title: 'Title: Z-A',
                icon: Icons.sort_by_alpha,
                option: SortOption.titleZA,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required IconData icon,
    required SortOption option,
  }) {
    bool isSelected = _currentSortOption == option;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.black54,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'MainFont1',
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          _currentSortOption = option;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          // margin: EdgeInsets.only(top: 30),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.black,
                  overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                  indicatorColor: Colors.black,
                  dividerColor: WidgetStateColor.resolveWith(
                        (states) => Colors.black,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  // padding: EdgeInsets.all(4),
                  // indicator: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(25),
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.black.withOpacity(0.1),
                  //       blurRadius: 4,
                  //       offset: Offset(0, 2),
                  //     ),
                  //   ],
                  // ),
                  // labelColor: Colors.black,
                  // unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Events",
                          style: TextStyle(
                            fontFamily: "MainFont",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Your Activities",
                          style: TextStyle(
                            fontFamily: "MainFont",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 10),
                _buildSortFilterSection(),
                Expanded(
                  child: TabBarView(
                    children: [
                      // First Tab: FacultyEvent
                      _buildEventsList1(fetchProgramDetails()),

                      // Second Tab: Your Activities
                      _buildEventsList2(fetchUserActivities()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // onPressed: () => {},
        onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) =>FacultyEventDetailsFilling(),)),
        label: const Text(
          'Add Event',
          style: TextStyle(fontFamily: 'MainFont', color: Colors.white),
        ),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildEventsList1(Future<List<ProgramDetails>> futureEvents) {
    return FutureBuilder<List<ProgramDetails>>(
      future: futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading events',
                  style: TextStyle(fontFamily: "MainFont", fontSize: 16),
                ),
              ],
            ),
          );
        }

        List<ProgramDetails> programList = snapshot.data ?? [];

        if (programList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No events found',
                  style: TextStyle(
                    fontFamily: "MainFont",
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        // Apply the current sort option
        _sortPrograms(programList);

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemBuilder: (context, index) {
            ProgramDetails programDetails = programList[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 5,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // if (futureEvents == fetchProgramDetails()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacultyEventDetails(eventId: programDetails.id),
                      ),
                    );
                  // } else {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => StudentParticipated(
                    //       eventId: programDetails.id,
                    //       email: user!.email,
                    //     ),
                    //   ),
                    // );

                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.event_note,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  programDetails.programDetails,
                                  style: TextStyle(
                                    fontFamily: "MainFont",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      getDate(programDetails.date),
                                      style: TextStyle(
                                        fontFamily: "MainFont1",
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      programDetails.time,
                                      style: TextStyle(
                                        fontFamily: "MainFont1",
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: programList.length,
        );
      },
    );
  }
  Widget _buildEventsList2(Future<List<ProgramDetails>> futureEvents) {
    return FutureBuilder<List<ProgramDetails>>(
      future: futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading events',
                  style: TextStyle(fontFamily: "MainFont", fontSize: 16),
                ),
              ],
            ),
          );
        }

        List<ProgramDetails> programList = snapshot.data ?? [];

        if (programList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No events found',
                  style: TextStyle(
                    fontFamily: "MainFont",
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        // Apply the current sort option
        _sortPrograms(programList);

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemBuilder: (context, index) {
            ProgramDetails programDetails = programList[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 5,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // if (futureEvents == fetchProgramDetails()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacultyEventFullDetails(eventId: programDetails.id),
                      ),
                    );
                  // } else {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => StudentParticipated(
                    //       eventId: programDetails.id,
                    //       email: user!.email,
                    //     ),
                    //   ),
                    // );

                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.event_note,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  programDetails.programDetails,
                                  style: TextStyle(
                                    fontFamily: "MainFont",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      getDate(programDetails.date),
                                      style: TextStyle(
                                        fontFamily: "MainFont1",
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      programDetails.time,
                                      style: TextStyle(
                                        fontFamily: "MainFont1",
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: programList.length,
        );
      },
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
    return date;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  // Future<List<ProgramDetails>> fetchUserActivities() async {
  //   try {
  //     QuerySnapshot userQuery = await FirebaseFirestore.instance
  //         .collection('events')
  //         .where('uniqueName', isEqualTo: user?.email)
  //         .get();
  //
  //     if (userQuery.docs.isNotEmpty) {
  //       DocumentSnapshot userDoc = userQuery.docs.first;
  //       List<dynamic> activityIds = userDoc['activities'] ?? [];
  //       List<ProgramDetails> userActivities = await fetchProgramDetailsByIds(activityIds);
  //       return userActivities;
  //     } else {
  //       print('User not found');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching user activities: $e');
  //     return [];
  //   }
  // }
  Future<List<ProgramDetails>> fetchUserActivities() async {
    try {
      final email = user?.email;
      if (email == null) {
        print('User email is null');
        return [];
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('uniqueName', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No matching documents found');
        return [];
      }

      List<ProgramDetails> userActivities = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return ProgramDetails(
          programDetails: data['programDetails'] ?? '',
          date: data['startDate'] ?? '',
          time: data['startTime'] ?? '',
          id: doc.id,
        );
      }).toList();

      return userActivities;
    } catch (e) {
      print('Error fetching user activities: $e');
      return [];
    }
  }

  Future<List<ProgramDetails>> fetchProgramDetailsByIds(List<dynamic> activityIds) async {
    try {
      List<ProgramDetails> programList = [];

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
}

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
        ),
      ),
      home: FacultyEvent(),
    ),
  );
}