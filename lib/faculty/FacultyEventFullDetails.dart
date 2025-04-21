import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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

  void navigateToQRScannerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          eventId: widget.eventId,
          isFeedbackRequired: eventData?['feedback'] == 1,
        ),
      ),
    );
  }

  void toggleFeedbackStatus() async {
    try {
      int currentStatus = eventData?['takeFeedback'] ?? 0;
      int newStatus = currentStatus == 1 ? 0 : 1;

      await _firestore.collection('events').doc(widget.eventId).update({
        'takeFeedback': newStatus
      });

      setState(() {
        if (eventData != null) {
          eventData!['takeFeedback'] = newStatus;
        }
      });

      showToast(newStatus == 1
          ? 'Feedback collection enabled'
          : 'Feedback collection disabled');
    } catch (e) {
      print('Error toggling feedback status: $e');
      showToast('Failed to update feedback status');
    }
  }

  void navigateToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventReportScreen(eventId: widget.eventId),
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

            // Action Buttons
            SizedBox(height: 20),
            buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildActionButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: navigateToQRScannerScreen,
              icon: Icon(Icons.qr_code_scanner),
              label: Text('Take Attendance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            if (eventData?['feedback'] == 1)
              ElevatedButton.icon(
                onPressed: toggleFeedbackStatus,
                icon: Icon(
                    (eventData?['takeFeedback'] == 1)
                        ? Icons.feedback
                        : Icons.feedback_outlined
                ),
                label: Text(
                    (eventData?['takeFeedback'] == 1)
                        ? 'Disable Feedback'
                        : 'Enable Feedback'
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (eventData?['takeFeedback'] == 1)
                      ? Colors.green
                      : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: navigateToReportScreen,
          icon: Icon(Icons.assessment),
          label: Text('View Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
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

// QR Scanner Screen
class QRScannerScreen extends StatefulWidget {
  final String eventId;
  final bool isFeedbackRequired;

  QRScannerScreen({required this.eventId, required this.isFeedbackRequired});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasScanned = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      // For Android
      controller!.pauseCamera();
      // For iOS
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!hasScanned && scanData.code != null) {
        setState(() {
          hasScanned = true;
        });

        controller.pauseCamera();
        await processQRCode(scanData.code!);
      }
    });
  }

  Future<void> processQRCode(String qrCode) async {
    try {
      // Assuming the QR code contains the student's email
      String studentEmail = qrCode;

      // Determine which array to update based on feedback requirement
      String arrayField = widget.isFeedbackRequired ? 'attendance' : 'finalAttendance';

      // Get current attendance array
      DocumentSnapshot eventDoc = await _firestore
          .collection('events')
          .doc(widget.eventId)
          .get();

      List<dynamic> currentAttendance = [];
      if (eventDoc.exists) {
        Map<String, dynamic> data = eventDoc.data() as Map<String, dynamic>;
        currentAttendance = List<dynamic>.from(data[arrayField] ?? []);
      }

      // Check if student is already in attendance
      if (currentAttendance.contains(studentEmail)) {
        showMessage('Student already marked present');
      } else {
        // Add student to attendance
        currentAttendance.add(studentEmail);

        // Update Firestore
        await _firestore.collection('events').doc(widget.eventId).update({
          arrayField: currentAttendance
        });

        showMessage('Attendance marked successfully');
      }
    } catch (e) {
      print('Error processing QR code: $e');
      showMessage('Failed to mark attendance');
    } finally {
      // After processing, allow user to scan another QR code
      if (mounted) {
        setState(() {
          hasScanned = false;
        });
        controller?.resumeCamera();
      }
    }
  }

  void showMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Align QR code within the frame',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    hasScanned ? 'Processing...' : 'Ready to scan',
                    style: TextStyle(
                      color: hasScanned ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Event Report Screen
class EventReportScreen extends StatefulWidget {
  final String eventId;

  EventReportScreen({required this.eventId});

  @override
  _EventReportScreenState createState() => _EventReportScreenState();
}

class _EventReportScreenState extends State<EventReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> attendanceData = [];
  Map<String, List<String>> departmentMap = {};
  String currentView = 'departments';
  String selectedDepartment = '';
  String selectedClass = '';
  String selectedDivision = '';

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      // Fetch event data to get attendance list
      DocumentSnapshot eventDoc = await _firestore
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (!eventDoc.exists) {
        setState(() {
          isLoading = false;
        });
        showToast('Event not found');
        return;
      }

      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

      // Determine which array to use based on feedback requirement
      String arrayField = eventData['feedback'] == 1 ? 'finalAttendance' : 'attendance';

      // Fallback to the other array if the primary one is empty
      List<dynamic> attendanceEmails = [];
      if (eventData[arrayField] != null && (eventData[arrayField] as List).isNotEmpty) {
        attendanceEmails = List<dynamic>.from(eventData[arrayField]);
      } else {
        // Try the other array as fallback
        String fallbackField = arrayField == 'finalAttendance' ? 'attendance' : 'finalAttendance';
        if (eventData[fallbackField] != null) {
          attendanceEmails = List<dynamic>.from(eventData[fallbackField]);
        }
      }

      print('Found ${attendanceEmails.length} emails in attendance');

      if (attendanceEmails.isEmpty) {
        setState(() {
          isLoading = false;
        });
        showToast('No attendance data found');
        return;
      }

      // Fetch user data for each email in attendance
      List<Map<String, dynamic>> userData = [];

      for (String email in attendanceEmails) {
        print('Processing email: $email');
        try {
          QuerySnapshot userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            Map<String, dynamic> user = userQuery.docs.first.data() as Map<String, dynamic>;
            userData.add({
              'email': email,
              'department': user['department'] ?? 'Unknown',
              'class': user['class'] ?? 'Unknown',
              'division': user['division'] ?? 'Unknown',
              'rollNumber': user['rollNumber'] ?? 'Unknown',
              'name': user['name'] ?? 'Unknown',
            });
            print('Added user data for $email');
          } else {
            print('No user found for email: $email');
            // Add with default values so the email is still included
            userData.add({
              'email': email,
              'department': 'Unknown',
              'class': 'Unknown',
              'division': 'Unknown',
              'rollNumber': 'Unknown',
              'name': email.split('@')[0], // Use part of email as name
            });
          }
        } catch (e) {
          print('Error fetching user data for $email: $e');
          // Still add the email with placeholder data
          userData.add({
            'email': email,
            'department': 'Error',
            'class': 'Error',
            'division': 'Error',
            'rollNumber': 'Error',
            'name': email,
          });
        }
      }

      print('Processed ${userData.length} user records');

      // Process data to create department mapping
      Map<String, List<String>> deptMap = {};
      for (var user in userData) {
        String dept = user['department'];
        if (!deptMap.containsKey(dept)) {
          deptMap[dept] = [];
        }
      }

      print('Created department map with ${deptMap.keys.length} departments');

      setState(() {
        attendanceData = userData;
        departmentMap = deptMap;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching attendance data: $e');
      showToast('Failed to load attendance data: ${e.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showToast(String message) {
    print(message); // Also log to console for debugging
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG, // Show longer for better visibility
      gravity: ToastGravity.CENTER, // Show in center for visibility
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  // Get unique departments
  List<String> getDepartments() {
    Set<String> departments = {};
    for (var user in attendanceData) {
      departments.add(user['department']);
    }
    return departments.toList()..sort();
  }

  // Get unique classes for selected department
  List<String> getClassesForDepartment(String department) {
    Set<String> classes = {};
    for (var user in attendanceData) {
      if (user['department'] == department) {
        classes.add(user['class']);
      }
    }
    return classes.toList()..sort();
  }

  // Get unique divisions for selected class in selected department
  List<String> getDivisionsForClass(String department, String classYear) {
    Set<String> divisions = {};
    for (var user in attendanceData) {
      if (user['department'] == department && user['class'] == classYear) {
        divisions.add(user['division']);
      }
    }
    return divisions.toList()..sort();
  }

  // Get students for selected division in selected class in selected department
  List<Map<String, dynamic>> getStudentsForDivision(String department, String classYear, String division) {
    List<Map<String, dynamic>> students = [];
    for (var user in attendanceData) {
      if (user['department'] == department &&
          user['class'] == classYear &&
          user['division'] == division) {
        students.add(user);
      }
    }
    // Sort by roll number
    students.sort((a, b) {
      if (a['rollNumber'] == 'Unknown' || a['rollNumber'] == 'Error') return 1;
      if (b['rollNumber'] == 'Unknown' || b['rollNumber'] == 'Error') return -1;
      return a['rollNumber'].toString().compareTo(b['rollNumber'].toString());
    });
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Report'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (currentView != 'departments')
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  if (currentView == 'students') {
                    currentView = 'divisions';
                  } else if (currentView == 'divisions') {
                    currentView = 'classes';
                  } else if (currentView == 'classes') {
                    currentView = 'departments';
                    selectedDepartment = '';
                  }
                });
              },
            ),
          // Debug button to show raw data
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Debug Info'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total Records: ${attendanceData.length}'),
                        SizedBox(height: 10),
                        Text('First 5 Records:'),
                        ...attendanceData.take(5).map((user) {
                          return Text('• ${user['email']} (${user['department']})');
                        }).toList(),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : attendanceData.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No attendance data available',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                fetchAttendanceData();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case 'departments':
        return _buildDepartmentsView();
      case 'classes':
        return _buildClassesView();
      case 'divisions':
        return _buildDivisionsView();
      case 'students':
        return _buildStudentsView();
      default:
        return _buildDepartmentsView();
    }
  }

  Widget _buildDepartmentsView() {
    List<String> departments = getDepartments();

    if (departments.isEmpty) {
      return Center(child: Text('No department data found'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Departments (${departments.length})',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: departments.length,
            itemBuilder: (context, index) {
              String department = departments[index];
              // Count students in this department
              int count = attendanceData.where((user) => user['department'] == department).length;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(department),
                  subtitle: Text('$count students'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    setState(() {
                      selectedDepartment = department;
                      currentView = 'classes';
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassesView() {
    List<String> classes = getClassesForDepartment(selectedDepartment);

    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No classes found for $selectedDepartment'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentView = 'departments';
                });
              },
              child: Text('Back to Departments'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Classes - $selectedDepartment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              String classYear = classes[index];
              // Count students in this class
              int count = attendanceData.where((user) =>
              user['department'] == selectedDepartment &&
                  user['class'] == classYear).length;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(classYear),
                  subtitle: Text('$count students'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    setState(() {
                      selectedClass = classYear;
                      currentView = 'divisions';
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDivisionsView() {
    List<String> divisions = getDivisionsForClass(selectedDepartment, selectedClass);

    if (divisions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No divisions found for $selectedClass in $selectedDepartment'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentView = 'classes';
                });
              },
              child: Text('Back to Classes'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Divisions - $selectedClass ($selectedDepartment)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: divisions.length,
            itemBuilder: (context, index) {
              String division = divisions[index];
              // Count students in this division
              int count = attendanceData.where((user) =>
              user['department'] == selectedDepartment &&
                  user['class'] == selectedClass &&
                  user['division'] == division).length;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(division),
                  subtitle: Text('$count students'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    setState(() {
                      selectedDivision = division;
                      currentView = 'students';
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsView() {
    List<Map<String, dynamic>> students = getStudentsForDivision(
        selectedDepartment, selectedClass, selectedDivision);

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No students found in $selectedDivision division'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentView = 'divisions';
                });
              },
              child: Text('Back to Divisions'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Students - $selectedDivision ($selectedClass, $selectedDepartment)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Total: ${students.length} students'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.account_circle_outlined,size: 30,color: Colors.black,),
                  // leading: CircleAvatar(
                  //   child: Text(student['rollNumber'].toString().substring(0, 1)),
                  //   backgroundColor: Colors.blue,
                  //   foregroundColor: Colors.white,
                  // ),
                  title: Text(student['name']),
                  subtitle: Text(student['email']),
                  trailing: Text('Roll: ${student['rollNumber']}'),
                ),
              );
            },
          ),
        ),
      ],
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