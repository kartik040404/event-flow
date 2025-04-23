import 'dart:io';

import 'package:excel/excel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
class AdminSelfEventFullDetails extends StatefulWidget {
  final String eventId;

  AdminSelfEventFullDetails({required this.eventId});

  @override
  _AdminSelfEventFullDetailsState createState() => _AdminSelfEventFullDetailsState();
}

class _AdminSelfEventFullDetailsState extends State<AdminSelfEventFullDetails> {
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
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _hasUploadError = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Cloudinary credentials - replace with your actual values
  final String cloudName = 'dp7uduwn8';
  final String uploadPreset = 'Preset'; // Create an unsigned upload preset in Cloudinary dashboard
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
          } else if (permissionStatus == 'approved') {
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
  Future<void> _uploadToCloudinary(File imageFile) async {
    setState(() {
      _isUploading = true;
      _hasUploadError = false;
      _errorMessage = '';
    });

    try {
      // Using unsigned upload with an upload preset
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Create multipart request
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resStream = await response.stream.bytesToString();
        final data = json.decode(resStream);
        setState(() {
          _uploadedImageUrl = data['secure_url'];
          _hasUploadError = false;
        });
        try {
          await FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .update({'profileUrl': _uploadedImageUrl});
        } catch (e) {
          print('Error updating profileUrl: $e');
        }
        _showSuccessSnackBar('Image uploaded successfully!');
      } else {
        final resStream = await response.stream.bytesToString();
        setState(() {
          _hasUploadError = true;
          _errorMessage = 'Server responded with code ${response.statusCode}: $resStream';
        });
        _showErrorSnackBar('Upload failed. Please try again.');
      }
    } catch (e) {
      setState(() {
        _hasUploadError = true;
        _errorMessage = e.toString();
      });
      _showErrorSnackBar('Upload failed. Please check your connection.');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(12),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(12),
        duration: Duration(seconds: 3),
      ),
    );
  }
  Future<void> _pickImage() async {
    try {
      setState(() {
        _hasUploadError = false;
        _errorMessage = '';
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadToCloudinary(_selectedImage!);
      }
    } catch (e) {
      setState(() {
        _hasUploadError = true;
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
      _showErrorSnackBar('Failed to pick image');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      setState(() {
        _hasUploadError = false;
        _errorMessage = '';
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadToCloudinary(_selectedImage!);
      }
    } catch (e) {
      setState(() {
        _hasUploadError = true;
        _errorMessage = 'Failed to take photo: ${e.toString()}';
      });
      _showErrorSnackBar('Failed to take photo');
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              'Organizer Information',
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
                buildDetailRow('Title', eventData?['title'] ?? 'N/A'),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Upload Your Image',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'File should be JPEG, PNG or WebP',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // Image Container
                  Container(
                    height: 380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _isUploading
                          ? _buildLoadingContainer(isDarkMode)
                          : _uploadedImageUrl != null
                          ? _buildNetworkImageContainer()
                          : _selectedImage != null
                          ? _buildLocalImageContainer()
                          : _buildPlaceholderContainer(isDarkMode),
                    ),
                  ),

                  if (_hasUploadError)
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Error: $_errorMessage',
                        style: TextStyle(color: Colors.red[800], fontSize: 14),
                      ),
                    ),



                  SizedBox(height: 32),

                  // Upload Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickImage,
                          icon: Icon(Icons.photo_library),
                          label: Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isDarkMode ? Colors.indigo[700] : Colors.indigo,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickFromCamera,
                          icon: Icon(Icons.camera_alt),
                          label: Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isDarkMode ? Colors.indigo[700] : Colors.indigo,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),            // Action Buttons
            SizedBox(height: 20),
            permissionStatus=="approved"?buildActionButtons():SizedBox()
          ],
        ),
      ),
    );
  }

  Widget buildActionButtons() {
    return Column(
      children: [
        Column(
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
            eventData?['feedback'] == 1? SizedBox(height:10,):SizedBox(height: 0,),

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

  Widget _buildNetworkImageContainer() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              body: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: PhotoView(
                    imageProvider: NetworkImage(_uploadedImageUrl!),
                    backgroundDecoration: BoxDecoration(color: Colors.black),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _uploadedImageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildPlaceholderContainer(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Color(0xFF2A2A2A) : Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 80,
              color: isDarkMode ? Colors.white38 : Colors.grey[400],
            ),
            SizedBox(height: eventData?['posterUrl']!=null?16:0),
            Text(
              'No event poster available',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            // SizedBox(height: 8),
            // Text(
            //   'Tap a button below to select an image',
            //   style: TextStyle(
            //     color: isDarkMode ? Colors.white38 : Colors.grey[500],
            //     fontSize: 14,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }
  Widget _buildLocalImageContainer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Text(
              'Ready to upload',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContainer(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Uploading to Cloudinary...',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
  bool isExporting = false;
  List<Map<String, dynamic>> attendanceData = [];
  Map<String, List<String>> departmentMap = {};
  String currentView = 'departments';
  String selectedDepartment = '';
  String selectedClass = '';
  String selectedDivision = '';
  String eventName = ''; // Add this to store event name

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  bool isFetchingFeedback = false;
  Map<String, int> ratingData = {
    'Very Bad': 0,
    'Bad': 0,
    'Average': 0,
    'Good': 0,
    'Excellent': 0,
  };
  bool showFeedback = false;

// Add this new function to fetch feedback data
  Future<void> fetchFeedbackData() async {
    setState(() {
      isFetchingFeedback = true;
    });

    try {
      // Fetch event document to get rating data
      DocumentSnapshot eventDoc = await _firestore
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (!eventDoc.exists) {
        showToast('Event not found');
        setState(() {
          isFetchingFeedback = false;
        });
        return;
      }

      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

      // Check if rating map exists
      if (eventData.containsKey('rating') && eventData['rating'] is Map) {
        Map<String, dynamic> ratingMap = Map<String, dynamic>.from(eventData['rating']);

        Map<String, int> parsedRatings = {
          'Very Bad': ratingMap['Very Bad'] ?? 0,
          'Bad': ratingMap['Bad'] ?? 0,
          'Average': ratingMap['Average'] ?? 0,
          'Good': ratingMap['Good'] ?? 0,
          'Excellent': ratingMap['Excellent'] ?? 0,
        };

        setState(() {
          ratingData = parsedRatings;
          showFeedback = true;
          isFetchingFeedback = false;
        });
      } else {
        showToast('No feedback data available for this event');
        setState(() {
          isFetchingFeedback = false;
        });
      }
    } catch (e) {
      print('Error fetching feedback data: $e');
      showToast('Failed to load feedback data: ${e.toString()}');
      setState(() {
        isFetchingFeedback = false;
      });
    }
  }

// Add this function to calculate overall rating
  double calculateOverallRating() {
    int totalResponses = ratingData.values.reduce((a, b) => a + b);
    if (totalResponses == 0) return 0;

    // Calculate weighted average (Very Bad=1, Bad=2, Average=3, Good=4, Excellent=5)
    double weightedSum =
        ratingData['Very Bad']! * 1 +
            ratingData['Bad']! * 2 +
            ratingData['Average']! * 3 +
            ratingData['Good']! * 4 +
            ratingData['Excellent']! * 5;

    // Convert to percentage (out of 5)
    return (weightedSum / (totalResponses * 5)) * 100;
  }

// Add this function to build the feedback view
  Widget _buildFeedbackView() {
    int totalResponses = ratingData.values.reduce((a, b) => a + b);
    double overallRating = calculateOverallRating();

    // Define rating colors
    Map<String, Color> ratingColors = {
      'Very Bad': Colors.red,
      'Bad': Colors.orange,
      'Average': Colors.amber,
      'Good': Colors.lightGreen,
      'Excellent': Colors.green,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Event Feedback',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    showFeedback = false;
                  });
                },
              ),
            ],
          ),
        ),

        // Overall rating display
        Center(
          child: Column(
            children: [
              Text(
                'Overall Rating',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: overallRating / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        overallRating >= 80 ? Colors.green :
                        overallRating >= 60 ? Colors.lightGreen :
                        overallRating >= 40 ? Colors.amber :
                        overallRating >= 20 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${overallRating.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalResponses responses',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Pie chart for rating distribution
        Expanded(
          child: totalResponses > 0
              ? Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Text(
                //   'Rating Distribution',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                SizedBox(height: 80),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: ratingData.entries.map((entry) {
                        double percentage = totalResponses > 0
                            ? (entry.value / totalResponses) * 100
                            : 0;
                        return PieChartSectionData(
                          color: ratingColors[entry.key]!,
                          value: entry.value.toDouble(),
                          title: entry.value > 0 ? '${percentage.toStringAsFixed(1)}%' : '',
                          radius: 100,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                SizedBox(height: 100),
                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: ratingData.entries.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: ratingColors[entry.key],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text('${entry.key} (${entry.value})'),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          )
              : Center(
            child: Text(
              'No feedback data available',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
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

      // Store event name for the report
      setState(() {
        eventName = eventData['title'] ?? 'Event';
      });

      // Determine which array to use based on feedback requirement
      // String arrayField = eventData['feedback'] == 1 ? 'finalAttendance' : 'attendance';
      String arrayField = 'finalAttendance';

      // Fallback to the other array if the primary one is empty
      List<dynamic> attendanceEmails = [];
      if (eventData[arrayField] != null && (eventData[arrayField] as List).isNotEmpty) {
        attendanceEmails = List<dynamic>.from(eventData[arrayField]);
      } else {
        // Try the other array as fallback
        // String fallbackField = arrayField == 'finalAttendance' ? 'attendance' : 'finalAttendance';
        String fallbackField = 'finalAttendance';
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

  // Export attendance data to Excel
  Future<void> exportToExcel() async {
    if (attendanceData.isEmpty) {
      showToast('No data to export');
      return;
    }

    setState(() {
      isExporting = true;
    });

    try {

      // Create a new Excel document
      final excel = Excel.createExcel();

      // Remove the default sheet
      excel.delete('Sheet1');

      // Create a summary sheet
      final Sheet summarySheet = excel['Summary'];

      // Add title and header to summary sheet
      int rowIndex = 0;

      // Title row
      var titleCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      titleCell.value = TextCellValue('Event Attendance Report: $eventName');
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );
      rowIndex += 2;

      // Date row
      var dateCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      dateCell.value = TextCellValue('Generated on: ${DateTime.now().toString().split('.')[0]}');
      rowIndex += 2;

      // Total attendees row
      var totalCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      totalCell.value = TextCellValue('Total Attendees: ${attendanceData.length}');
      totalCell.cellStyle = CellStyle(bold: true);
      rowIndex += 2;

      // Department summary header
      var deptHeaderCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      deptHeaderCell.value = TextCellValue('Department');
      deptHeaderCell.cellStyle = CellStyle(bold: true,             backgroundColorHex:  ExcelColor.fromHexString("FFCCCCCC")
      );

      var countHeaderCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
      countHeaderCell.value = TextCellValue('Count');
      countHeaderCell.cellStyle = CellStyle(bold: true,             backgroundColorHex:  ExcelColor.fromHexString("FFCCCCCC")
      );
      rowIndex++;

      // Get departments and counts
      Map<String, int> departmentCounts = {};
      for (var user in attendanceData) {
        String dept = user['department'];
        departmentCounts[dept] = (departmentCounts[dept] ?? 0) + 1;
      }

      // Add department counts to summary
      departmentCounts.forEach((dept, count) {
        var deptCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
        deptCell.value = TextCellValue(dept);

        var countCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
        countCell.value = TextCellValue(count.toString());

        rowIndex++;
      });

      // Create detailed sheet with all attendees
      final Sheet detailSheet = excel['All Attendees'];

      // Add header row
      List<String> headers = ['Name', 'Email', 'Department', 'Class', 'Division', 'Roll Number'];
      for (int i = 0; i < headers.length; i++) {
        var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
            bold: true,
            backgroundColorHex:  ExcelColor.fromHexString("FFCCCCCC")

        );
      }

      // Add data rows
      for (int i = 0; i < attendanceData.length; i++) {
        var student = attendanceData[i];
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = TextCellValue(student['name']);
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = TextCellValue(student['email']);
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = TextCellValue(student['department']);
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = TextCellValue(student['class']);
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
            .value = TextCellValue(student['division']);
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
            .value = TextCellValue(student['rollNumber'].toString());
      }

      // Auto-size columns for better readability
      for (int i = 0; i < headers.length; i++) {
        detailSheet.setColumnWidth(i, 15.0);
      }

      // Create department-wise sheets
      for (String department in getDepartments()) {
        // Skip creating sheets for unknown or error departments
        if (department == 'Unknown' || department == 'Error') continue;

        // Create sheet for this department
        final Sheet deptSheet = excel[department];

        // Add header row with the same headers
        for (int i = 0; i < headers.length; i++) {
          var cell = deptSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.value = TextCellValue(headers[i]);
          cell.cellStyle = CellStyle(
              bold: true,
              backgroundColorHex:  ExcelColor.fromHexString("FFCCCCCC")

          );
        }

        // Filter students by department
        List<Map<String, dynamic>> deptStudents = attendanceData
            .where((user) => user['department'] == department)
            .toList();

        // Sort by class, then division, then roll number
        deptStudents.sort((a, b) {
          int classComp = a['class'].compareTo(b['class']);
          if (classComp != 0) return classComp;

          int divComp = a['division'].compareTo(b['division']);
          if (divComp != 0) return divComp;

          if (a['rollNumber'] == 'Unknown' || a['rollNumber'] == 'Error') return 1;
          if (b['rollNumber'] == 'Unknown' || b['rollNumber'] == 'Error') return -1;

          return a['rollNumber'].toString().compareTo(b['rollNumber'].toString());
        });

        // Add students to this sheet
        for (int i = 0; i < deptStudents.length; i++) {
          var student = deptStudents[i];
          deptSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
              .value = TextCellValue(student['name']);
          deptSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
              .value = TextCellValue(student['email']);
          deptSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
              .value = TextCellValue(student['department']);
          deptSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
              .value = TextCellValue(student['class']);
          deptSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
              .value = TextCellValue(student['division']);
          deptSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
              .value = TextCellValue(student['rollNumber'].toString());
        }

        // Auto-size columns
        for (int i = 0; i < headers.length; i++) {
          deptSheet.setColumnWidth(i, 15.0);
        }
      }

      // Get the document directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'attendance_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String path = '${directory.path}/$fileName';

      // Save the Excel file
      final fileBytes = excel.save();
      if (fileBytes != null) {
        File excelFile = File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        print('================================Excel file saved at: $path');

        // Share the file
        await Share.shareXFiles(
          [XFile(path)],
          text: 'Attendance Report for $eventName',
        );

        showToast('Excel report generated and ready to share');
      } else {
        showToast('Failed to generate Excel file');
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      showToast('Failed to export data: ${e.toString()}');
    } finally {
      setState(() {
        isExporting = false;
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
          if (!isLoading && attendanceData.isNotEmpty)
            IconButton(
              icon: Icon(Icons.file_download),
              tooltip: 'Export to Excel',
              onPressed: isExporting ? null : exportToExcel,
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
          : Column(
        children: [
          // Export button at the top of the screen
          if (!isLoading && attendanceData.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isExporting ? null : exportToExcel,
                      icon: Icon(Icons.file_download),
                      label: Text('Export Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: Size(0, 50),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isFetchingFeedback
                          ? null
                          : () {
                        if (showFeedback) {
                          setState(() {
                            showFeedback = false;
                          });
                        } else {
                          fetchFeedbackData();
                        }
                      },
                      icon: Icon(Icons.bar_chart),
                      label: Text('Feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(0, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),

// Update this part of the build method to handle the feedback view
          Expanded(
            child: isFetchingFeedback
                ? Center(child: CircularProgressIndicator())
                : showFeedback
                ? _buildFeedbackView()
                : _buildCurrentView(),
          ),
        ],
      ),

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

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Storage Permission Required'),
        content: Text(
          'This app needs storage permission to save the attendance report. '
              'Please grant storage permission in app settings.',
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Open Settings'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
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