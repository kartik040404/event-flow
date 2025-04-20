import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentParticipated extends StatefulWidget {
  final String eventId;
  final String? email;

  StudentParticipated({
    Key? key,
    required this.eventId,
    required this.email,
  }) : super(key: key);

  @override
  _StudentParticipatedState createState() => _StudentParticipatedState();
}

class _StudentParticipatedState extends State<StudentParticipated> {
  late String programDetails = '';
  late String date = '';
  late String time = '';
  late bool isLoading;
  int takeFeedback = 0;
  bool userHasGivenFeedback = false;
  bool isUserInAttendance = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchData();
  }

  Future<void> fetchData() async {
    print("================================${widget.eventId}");
    try {
      // Direct fetch using document ID
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventSnapshot.exists) {
        Map<String, dynamic> eventData = eventSnapshot.data() as Map<String, dynamic>;

        // Check if user is in attendance array
        bool userInAttendance = false;
        bool userFeedbackGiven = false;

        if (eventData.containsKey('attendance') && widget.email != null) {
          // Check if attendance is stored as an array
          if (eventData['attendance'] is List) {
            List<dynamic> attendanceList = eventData['attendance'] as List<dynamic>;
            userInAttendance = attendanceList.contains(widget.email);
          }

          // Check if the user is in the finalAttendance array (has given feedback)
          if (eventData.containsKey('finalAttendance') && eventData['finalAttendance'] is List) {
            List<dynamic> finalAttendanceList = eventData['finalAttendance'] as List<dynamic>;
            userFeedbackGiven = finalAttendanceList.contains(widget.email);
          }
        }

        setState(() {
          programDetails = eventData['programDetails'] ?? '';
          date = eventData['startDate'] ?? '';
          time = eventData['startTime'] ?? '';
          takeFeedback = eventData['takeFeedback'] ?? 0;
          isLoading = false;
          isUserInAttendance = userInAttendance;
          userHasGivenFeedback = userFeedbackGiven;
        });

        print('isUserInAttendance: $isUserInAttendance'); // Debug print
        print('userHasGivenFeedback: $userHasGivenFeedback'); // Debug print
        print('takeFeedback: $takeFeedback'); // Debug print
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "Event not found",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error loading event details",
        backgroundColor: Colors.red,
      );
    }
  }

  void updateFeedbackStatus() {
    setState(() {
      userHasGivenFeedback = true;
    });
  }

  Widget buildQrCode(String data) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 200.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Details",
          style: TextStyle(fontFamily: 'MainFont'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.event,
                  size: 80,
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
                    programDetails,
                    style: TextStyle(
                      fontFamily: 'MainFont',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: "Date",
                    content: date,
                    color: Colors.green.shade100,
                    iconColor: Colors.green.shade800,
                  ),
                  SizedBox(height: 15),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: "Time",
                    content: time,
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange.shade800,
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        String? qrData = widget.email;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                "Your QR Code",
                                style: TextStyle(fontFamily: 'MainFont'),
                                textAlign: TextAlign.center,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  buildQrCode(qrData!),
                                  SizedBox(height: 10),
                                  Text(
                                    "Show this QR code to the event coordinator",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: 'MainFont1'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Close"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(30),
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        elevation: 8,
                      ),
                      child: Icon(
                        Icons.qr_code,
                        size: 40,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Text(
                      "Show QR Code",
                      style: TextStyle(
                        fontFamily: 'MainFont',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (takeFeedback == 1 && isUserInAttendance && !userHasGivenFeedback)
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 30),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FeedbackDialog(
                                  eventId: widget.eventId,
                                  email: widget.email!,
                                  onSubmitFeedback: updateFeedbackStatus,
                                );
                              },
                            ).then((value) {
                              if (value != null) {
                                // Handle the selected stars value
                                print('Selected stars: $value');
                              }
                            });
                          },
                          icon: Icon(Icons.star),
                          label: Text(
                            "Rate This Event",
                            style: TextStyle(fontFamily: 'MainFont'),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (takeFeedback == 1 && !isUserInAttendance)
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Card(
                          elevation: 0,
                          color: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Please mark your attendance first",
                                  style: TextStyle(
                                    fontFamily: 'MainFont',
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (takeFeedback == 1 && userHasGivenFeedback)
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Card(
                          elevation: 0,
                          color: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Thank you for your feedback!",
                                  style: TextStyle(
                                    fontFamily: 'MainFont',
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
            Expanded(
              child: Column(
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
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackDialog extends StatefulWidget {
  final VoidCallback onSubmitFeedback;
  final String eventId;
  final String email;

  FeedbackDialog({
    Key? key,
    required this.eventId,
    required this.email,
    required this.onSubmitFeedback,
  }) : super(key: key);

  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int selectedStars = 0;
  final List<String> feedbackOptions = [
    'Very Bad',
    'Bad',
    'Average',
    'Good',
    'Excellent'
  ];

  void submitFeedback() async {
    if (selectedStars > 0) {
      String selectedFeedbackType = feedbackOptions[selectedStars - 1];

      try {
        // Verify user is in attendance array before proceeding
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .get();

        if (eventDoc.exists) {
          Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

          // Check if attendance array exists and contains the email
          if (eventData.containsKey('attendance') &&
              eventData['attendance'] is List &&
              (eventData['attendance'] as List).contains(widget.email)) {

            // Update totalFeedback count
            await updateTotalFeedback(selectedStars);

            // Update feedback type count
            await updateFeedbackType(selectedFeedbackType);

            // Add user to finalAttendance array and remove from attendance array
            await moveTofinalAttendance();

            // Call the callback to update UI
            widget.onSubmitFeedback();

            Navigator.pop(context, selectedStars);
          } else {
            Fluttertoast.showToast(
              msg: "Please mark your attendance first",
              backgroundColor: Colors.orange,
            );
          }
        }
      } catch (e) {
        print('Error submitting feedback: $e');
        Fluttertoast.showToast(
          msg: "Error submitting feedback",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> updateTotalFeedback(int stars) async {
    try {
      DocumentReference eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId);

      await eventRef.update({
        'totalFeedBack': FieldValue.increment(stars),
      });
    } catch (e) {
      print('Error updating total feedback: $e');
      Fluttertoast.showToast(
        msg: "Error updating feedback",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> updateFeedbackType(String feedbackType) async {
    try {
      DocumentReference eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId);

      await eventRef.update({
        'rating.$feedbackType': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating feedback type: $e');
    }
  }

  Future<void> moveTofinalAttendance() async {
    try {
      DocumentReference eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId);

      // Add user to finalAttendance array and remove from attendance array
      await eventRef.update({
        'finalAttendance': FieldValue.arrayUnion([widget.email]),
        // 'attendance': FieldValue.arrayRemove([widget.email])
      });

      Fluttertoast.showToast(
        msg: "Thanks for your feedback!",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print('Error moving user to finalAttendance: $e');
      Fluttertoast.showToast(
        msg: "Error updating attendance status",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review,
                color: Colors.amber.shade700,
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Rate This Event',
              style: TextStyle(
                fontFamily: 'MainFont',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStars = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              selectedStars > 0 ? feedbackOptions[selectedStars - 1] : 'Select your rating',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'MainFont1',
                color: selectedStars > 0 ? Colors.black87 : Colors.grey,
              ),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'MainFont',
                      color: Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedStars > 0
                      ? () {
                    submitFeedback();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.amber.shade700,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontFamily: 'MainFont',
                      color: Colors.white,
                    ),
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