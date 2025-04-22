
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'StudentEventDetails.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key}) : super(key: key);

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
User? user = _auth.currentUser;
class _StudentHomeState extends State<StudentHome> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  Map<String, List> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();
  int _selectedIndex = 0;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    fetchDataFromFirestore();
  }

  fetchDataFromFirestore() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('events')
        .where('permission', isEqualTo: 'approved')
        .get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
      String date = doc['startDate'];
      String eventName = doc['programDetails'];
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
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40),
            child: Text(
              "Event Calendar",
              style: TextStyle(fontFamily: 'MainFont', fontSize: 40),
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


            rowHeight: 60,
            daysOfWeekHeight: 30,

            headerStyle:
            HeaderStyle(titleTextStyle: TextStyle(fontFamily: 'MainFont')),

            daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontFamily: 'MainFont'),
                weekendStyle: TextStyle(fontFamily: 'MainFont')
            ),
            calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(fontFamily: 'MainFont'),
                outsideTextStyle: TextStyle(fontFamily: 'MainFont'),
                weekNumberTextStyle: TextStyle(fontFamily: 'MainFont'),
                weekendTextStyle: TextStyle(fontFamily: 'MainFont'),
                tableBorder: TableBorder(
                    top: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                    horizontalInside: BorderSide(color: Colors.black),
                    verticalInside: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10))),
          ),
          myEventsList.isEmpty?Container():
          Container(
            margin: EdgeInsets.only(top: 10,),
            child: Text("Events :",style: TextStyle(fontFamily: "MainFont"),),
          ),


          // ...myEventsList.map(
          //         (myEvents) =>
          //
          //         InkWell(
          //           onTap: (){
          //             Navigator.push(context, MaterialPageRoute(builder: (context) => StudentEventDetails(programDetails: myEvents['eventTitle'], email: user!.email.toString()),));
          //           },
          //           child: Card(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Container(
          //                   child: Text(
          //                     'Event :   ${myEvents['eventTitle']}',
          //                     style: TextStyle(fontFamily: "MainFont"),
          //                   ),
          //                   margin: EdgeInsets.only(left: 10, top: 10),
          //                 ),
          //                 Row(
          //                   children: [
          //                     Container(
          //                       margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          //                       child: Text(
          //                         getDate(myEvents['date']),
          //                         style: TextStyle(fontFamily: "MainFont1"),
          //                       ),
          //                     ),
          //                     Expanded(
          //                       child: Align(
          //                         alignment: Alignment.centerRight,
          //                         child: Container(
          //                           margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
          //                           child: Text(
          //                             "Time : ${myEvents['time']}",
          //                             style: TextStyle(fontFamily: "MainFont1"),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //           ),
          //         )
          //
          // ),
          myEventsList.isEmpty
              ? Container(
            margin: EdgeInsets.only(top: 50),
            child: Center(
              child: Text(
                'No Events',
                style: TextStyle(fontFamily: 'MainFont',fontSize: 30,color: Colors.grey),
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: myEventsList.length,
              itemBuilder: (context, index) {
                var myEvents = myEventsList[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentEventDetails(
                         eventId: myEvents['id'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Event :   ${myEvents['eventTitle']}',
                            style:
                            TextStyle(fontFamily: "MainFont"),
                          ),
                          margin: EdgeInsets.only(left: 10, top: 10),
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: 10, top: 10, bottom: 10),
                              child: Text(
                                getDate(myEvents['date']),
                                style:
                                TextStyle(fontFamily: "MainFont1"),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 10, right: 10, bottom: 10),
                                  child: Text(
                                    "Time : ${myEvents['time']}",
                                    style: TextStyle(
                                        fontFamily: "MainFont1"),
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
            ),
          ),
        ],
      ),
    );
  }

  String getDate(String date) {

    DateTime parsedDate = DateTime.parse(date);

    DateTime currentDate = DateTime.now();

    if (isSameDay(parsedDate, currentDate)) {
      return "Today";
    }
    else if (isSameDay(parsedDate, currentDate.add(Duration(days: 1)))) {
      return "Tomorrow";
    }
    return "Date : ${date}";
  }
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}

