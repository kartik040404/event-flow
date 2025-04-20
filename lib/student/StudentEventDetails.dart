import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentEventDetails extends StatefulWidget {
  final String eventId;

  const StudentEventDetails({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<StudentEventDetails> createState() => _StudentEventDetailsState();
}

class _StudentEventDetailsState extends State<StudentEventDetails> {
  bool _loading = true;
  Map<String, dynamic> eventDetails = {};

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (doc.exists) {
        setState(() {
          eventDetails = doc.data()!;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print("Error fetching event details: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Event Details',
          style: TextStyle(
            fontFamily: 'MainFont',
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : eventDetails.isEmpty
          ? Center(
        child: Text(
          'Event not found',
          style: TextStyle(
            fontFamily: 'MainFont',
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.event,
                  size: 100,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventDetails['programDetails'] ?? 'No Title',
                    style: TextStyle(
                      fontFamily: 'MainFont',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    content: formatDate(eventDetails['startDate'] ?? ''),
                    color: Colors.green.shade100,
                    iconColor: Colors.green.shade800,
                  ),
                  SizedBox(height: 15),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: 'Time',
                    content: eventDetails['startTime'] ?? 'Not specified',
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange.shade800,
                  ),
                  if (eventDetails['location'] != null) ...[
                    SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Location',
                      content: eventDetails['location'],
                      color: Colors.purple.shade100,
                      iconColor: Colors.purple.shade800,
                    ),
                  ],
                  if (eventDetails['organizer'] != null) ...[
                    SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.people,
                      title: 'Organizer',
                      content: eventDetails['organizer'],
                      color: Colors.red.shade100,
                      iconColor: Colors.red.shade800,
                    ),
                  ],
                  SizedBox(height: 25),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'MainFont',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        eventDetails['description'] ?? 'No description available',
                        style: TextStyle(
                          fontFamily: 'MainFont1',
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  if (eventDetails['additionalInfo'] != null) ...[
                    SizedBox(height: 25),
                    Text(
                      'Additional Information',
                      style: TextStyle(
                        fontFamily: 'MainFont',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          eventDetails['additionalInfo'],
                          style: TextStyle(
                            fontFamily: 'MainFont1',
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'MainFont',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'MainFont',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}