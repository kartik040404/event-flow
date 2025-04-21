import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FacultyEventFullDetails extends StatefulWidget {
  final String eventId;

  FacultyEventFullDetails({required this.eventId});

  @override
  _FacultyEventFullDetailsState createState() => _FacultyEventFullDetailsState();
}

class _FacultyEventFullDetailsState extends State<FacultyEventFullDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  Map<String, dynamic>? eventData;
  String permissionStatus = '';
  Color statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      DocumentSnapshot eventDoc = await _firestore
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventDoc.exists) {
        setState(() {
          eventData = eventDoc.data() as Map<String, dynamic>;
          permissionStatus = eventData?['permission'] ?? 'pending';
          isLoading = false;

          // Set status color
          if (permissionStatus == 'pending') {
            statusColor = Colors.orange;
          } else if (permissionStatus == 'accepted') {
            statusColor = Colors.green;
          } else if (permissionStatus == 'rejected') {
            statusColor = Colors.red;
          }
        });
      } else {
        showToast('Event not found');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching event details: $e');
      showToast('Failed to load event details');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteEvent() async {
    try {
      await _firestore.collection('events').doc(widget.eventId).delete();
      showToast('Event deleted successfully');
      Navigator.of(context).pop(); // Go back after deletion
    } catch (e) {
      print('Error deleting event: $e');
      showToast('Failed to delete event');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  void navigateToControlScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventControlScreen(eventId: widget.eventId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (!isLoading &&
              (permissionStatus == 'pending' || permissionStatus == 'rejected'))
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Event'),
                    content: Text('Are you sure you want to delete this event?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteEvent();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: navigateToControlScreen,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : eventData == null
          ? Center(child: Text('No event data found'))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Status: ${permissionStatus.toUpperCase()}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Event details
            buildDetailCard(
              'Event Information',
              [
                buildDetailRow('Faculty Name', eventData?['facultyName'] ?? 'N/A'),
                buildDetailRow('Designation', eventData?['designation'] ?? 'N/A'),
                buildDetailRow('Department', eventData?['department'] ?? 'N/A'),
                buildDetailRow('Phone Number', eventData?['facultyPhoneNo'] ?? 'N/A'),
              ],
            ),

            buildDetailCard(
              'Program Details',
              [
                buildDetailRow('Details', eventData?['programDetails'] ?? 'N/A', isMultiline: true),
              ],
            ),

            buildDetailCard(
              'Event Schedule',
              [
                buildDetailRow('Start Date', eventData?['startDate'] ?? 'N/A'),
                buildDetailRow('End Date', eventData?['endDate'] ?? 'N/A'),
                buildDetailRow('Start Time', eventData?['startTime'] ?? 'N/A'),
                buildDetailRow('End Time', eventData?['endTime'] ?? 'N/A'),
              ],
            ),

            buildDetailCard(
              'Coordinator Information',
              [
                buildDetailRow('Name', eventData?['nameOfCoordinator'] ?? 'N/A'),
                buildDetailRow('Mobile Number', eventData?['mobileNoOfCoordinator'] ?? 'N/A'),
              ],
            ),

            buildDetailCard(
              'Guest Information',
              [
                buildDetailRow('Chief Guest', eventData?['nameOfChiefGuest'] ?? 'N/A', isMultiline: true),
                buildDetailRow('Number of Chief Guests', eventData?['noOfChiefGuest'] ?? 'N/A'),
                buildDetailRow('Number of Invitees', eventData?['noOfInvites'] ?? 'N/A'),
              ],
            ),

            if ((eventData?['selectedItems'] as List?)?.isNotEmpty ?? false)
              buildDetailCard(
                'Required Facilities',
                [
                  buildSelectedItemsList((eventData?['selectedItems'] as List).cast<String>()),
                ],
              ),

            buildDetailCard(
              'Feedback',
              [
                buildDetailRow('Feedback Required',
                    eventData?['feedback'] == 1 ? 'Yes' : 'No'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'MainFont',
              ),
            ),
            Divider(thickness: 1),
            SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontFamily: 'MainFont',
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'MainFont1',
            ),
          ),
          if (!isMultiline) SizedBox(height: 8),
          if (!isMultiline) Divider(height: 1),
        ],
      ),
    );
  }

  Widget buildSelectedItemsList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(fontFamily: 'MainFont1'),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Placeholder for the Event Control Screen
class EventControlScreen extends StatelessWidget {
  final String eventId;

  EventControlScreen({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Control'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Event Control Screen\nEvent ID: $eventId',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}