import 'package:event_flow/admin/AdminEventDetails.dart';
import 'package:event_flow/faculty/FacultyEventDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;

class _AdminHomeState extends State<AdminHome> with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, List> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();
  int _selectedIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
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
    fetchDataFromFirestore();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  fetchDataFromFirestore() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance
        .collection('events')
        .where('permission', isEqualTo: 'approved')
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
      String date = doc['startDate'];
      String eventName = doc['title'];
      String time = doc['startTime'];

      if (mySelectedEvents[date] != null) {
        mySelectedEvents[date]?.add({
          "eventTitle": eventName,
          "date": date,
          "time": time,
          "id": doc.id
        });
      } else {
        mySelectedEvents[date] = [
          {
            "eventTitle": eventName,
            "date": date,
            "time": time,
            "id": doc.id
          }
        ];
      }
    }

    setState(() {
      _loading = false;
    });
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    List myEventsList = _listOfDayEvents(_selectedDate!);
    myEventsList.sort((a, b) => a['time'].compareTo(b['time']));

    return Scaffold(
      body: _loading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
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
                    'Event Calendar',
                    style: TextStyle(
                      fontFamily: 'MainFont',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  titlePadding: EdgeInsets.only(left: 10,bottom: 15),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue[800]!, Colors.blue[500]!],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: Colors.blue[700],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  DateFormat('MMMM yyyy').format(_focusedDay),
                                  style: TextStyle(
                                    fontFamily: 'MainFont',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TableCalendar(
                            firstDay: DateTime(2024),
                            lastDay: DateTime(2026),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            onDaySelected: (selectedDay, focusedDay) {
                              if (!isSameDay(_selectedDate!, selectedDay)) {
                                setState(() {
                                  _selectedDate = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              }
                            },
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDate!, day);
                            },
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                            eventLoader: _listOfDayEvents,
                            rowHeight: 50,
                            daysOfWeekHeight: 30,
                            headerStyle: HeaderStyle(
                              formatButtonVisible: true,
                              titleCentered: true,
                              formatButtonDecoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              formatButtonTextStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'MainFont',
                              ),
                              titleTextStyle: TextStyle(
                                fontFamily: 'MainFont',
                                fontSize: 18,
                                color: Colors.blue[700],
                              ),
                              headerPadding: EdgeInsets.symmetric(vertical: 4),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: Colors.blue[700],
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: Colors.blue[700],
                              ),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                fontFamily: 'MainFont',
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                              weekendStyle: TextStyle(
                                fontFamily: 'MainFont',
                                color: Colors.red[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: TextStyle(
                                fontFamily: 'MainFont',
                              ),
                              outsideTextStyle: TextStyle(
                                fontFamily: 'MainFont',
                                color: Colors.grey[400],
                              ),
                              weekendTextStyle: TextStyle(
                                fontFamily: 'MainFont',
                                color: Colors.red[300],
                              ),
                              todayDecoration: BoxDecoration(
                                color: Colors.blue[200],
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.blue[700],
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: BoxDecoration(
                                color: Colors.red[400],
                                shape: BoxShape.circle,
                              ),
                              markerSize: 6,
                              markersMaxCount: 3,
                              cellMargin: EdgeInsets.all(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    myEventsList.isEmpty
                        ? Container()
                        : Container(
                      margin: EdgeInsets.only(
                        top: 20,
                        left: 20,
                        bottom: 8,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_available,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Events",
                            style: TextStyle(
                              fontFamily: "MainFont",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              myEventsList.isEmpty
                  ? SliverToBoxAdapter(
                child: Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 70,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Events',
                          style: TextStyle(
                            fontFamily: 'MainFont',
                            fontSize: 30,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    var myEvents = myEventsList[index];
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Card(
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
                                builder: (context) => AdminEventDetails(eventId: myEvents['id']),
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
                                            myEvents['eventTitle'],
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
                                                getDate(myEvents['date']),
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
                                                myEvents['time'],
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
                      ),
                    );
                  },
                  childCount: myEventsList.length,
                ),
              ),
            ],
          ),
        ),
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
    return DateFormat('MMM dd, yyyy').format(parsedDate);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}