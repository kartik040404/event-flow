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
      programDetails: data['title'] ?? '',
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
  SortOption _currentSortOption = SortOption.dateAscending;

  // Define blue theme colors
  final Color primaryBlue = Color(0xFF1A73E8);
  final Color lightBlue = Color(0xFFE8F0FE);
  final Color darkBlue = Color(0xFF0D47A1);
  final Color accentBlue = Color(0xFF4285F4);

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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lightBlue.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: accentBlue.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              fontFamily: 'MainFont',
              color: darkBlue,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                _showSortOptions();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: accentBlue.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getSortOptionText(),
                      style: TextStyle(
                        fontFamily: 'MainFont1',
                        color: darkBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: primaryBlue,
                      size: 28,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, lightBlue.withOpacity(0.3)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text(
                  'Sort Events',
                  style: TextStyle(
                    fontFamily: 'MainFont',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ),
              Divider(color: accentBlue.withOpacity(0.2), thickness: 1),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 24),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue.withOpacity(0.2) : lightBlue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? primaryBlue : accentBlue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'MainFont1',
          color: isSelected ? primaryBlue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: primaryBlue)
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 12, bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    labelColor: primaryBlue,
                    unselectedLabelColor: Colors.grey[600],
                    overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                    indicatorColor: primaryBlue,
                    indicatorWeight: 3,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(
                      fontFamily: "MainFont",
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: "MainFont",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event, size: 16),
                              SizedBox(width: 6),
                              Text("Events"),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline, size: 16),
                              SizedBox(width: 6),
                              Text("Your Activities"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSortFilterSection(),
                Expanded(
                  child: TabBarView(
                    children: [
                      // First Tab: StudentEvent
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => {},
      //   label: const Text(
      //     'History',
      //     style: TextStyle(fontFamily: 'MainFont', color: Colors.white, fontWeight: FontWeight.w600),
      //   ),
      //   icon: Icon(Icons.history, color: Colors.white),
      //   backgroundColor: primaryBlue,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(30),
      //   ),
      //   elevation: 4,
      // ),
    );
  }

  Widget _buildEventsList1(Future<List<ProgramDetails>> futureEvents) {
    return FutureBuilder<List<ProgramDetails>>(
      future: futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryBlue,
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
                Icon(Icons.event_busy, size: 72, color: accentBlue.withOpacity(0.6)),
                SizedBox(height: 20),
                Text(
                  'No events found',
                  style: TextStyle(
                    fontFamily: "MainFont",
                    fontSize: 18,
                    color: darkBlue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Check back later for upcoming events',
                  style: TextStyle(
                    fontFamily: "MainFont1",
                    fontSize: 14,
                    color: Colors.grey[600],
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentEventDetails(eventId: programDetails.id),
                    ),
                  );
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
              color: primaryBlue,
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
                Icon(Icons.event_busy, size: 72, color: accentBlue.withOpacity(0.6)),
                SizedBox(height: 20),
                Text(
                  'No participated events found',
                  style: TextStyle(
                    fontFamily: "MainFont",
                    fontSize: 18,
                    color: darkBlue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Join events to see them here',
                  style: TextStyle(
                    fontFamily: "MainFont1",
                    fontSize: 14,
                    color: Colors.grey[600],
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentParticipated(
                        eventId: programDetails.id,
                        email: user!.email,
                      ),
                    ),
                  );
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

  Future<List<ProgramDetails>> fetchUserActivities() async {
    try {
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
        primaryColor: Color(0xFF1A73E8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1A73E8),
          primary: Color(0xFF1A73E8),
        ),
      ),
      home: StudentEvent(),
    ),
  );
}