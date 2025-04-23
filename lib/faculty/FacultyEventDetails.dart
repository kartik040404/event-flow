import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';

class FacultyEventDetails extends StatefulWidget {
  final String eventId;

  const FacultyEventDetails({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<FacultyEventDetails> createState() => _FacultyEventDetailsState();
}

class _FacultyEventDetailsState extends State<FacultyEventDetails> {
  bool _loading = true;
  Map<String, dynamic> eventDetails = {};
  bool hasParticipated = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          : Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventDetails['title'] ?? 'No Title',
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
                      // Add space at the bottom for the floating button
                      // SizedBox(height: 100),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'Event Poster',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Image Container
                      Container(
                        height: eventDetails['posterUrl']!=null?380:120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child:
                            eventDetails['posterUrl']!=null?
                            _buildNetworkImageContainer()
                                :_buildPlaceholderContainer(isDarkMode)
                        ),
                      ),

                      // if (_hasUploadError)
                      //   Container(
                      //     margin: EdgeInsets.only(top: 16),
                      //     padding: EdgeInsets.all(12),
                      //     decoration: BoxDecoration(
                      //       color: Colors.red.withOpacity(0.1),
                      //       borderRadius: BorderRadius.circular(12),
                      //       border: Border.all(color: Colors.red.withOpacity(0.3)),
                      //     ),
                      //     child: Text(
                      //       'Error: $_errorMessage',
                      //       style: TextStyle(color: Colors.red[800], fontSize: 14),
                      //     ),
                      //   ),
                      //
                      // if (_uploadedImageUrl != null)
                      //   Container(
                      //     margin: EdgeInsets.only(top: 16),
                      //     padding: EdgeInsets.all(12),
                      //     decoration: BoxDecoration(
                      //       color: isDarkMode
                      //           ? Colors.indigo.withOpacity(0.2)
                      //           : Colors.indigo.withOpacity(0.1),
                      //       borderRadius: BorderRadius.circular(12),
                      //       border: Border.all(
                      //         color: isDarkMode
                      //             ? Colors.indigo.withOpacity(0.3)
                      //             : Colors.indigo.withOpacity(0.2),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
SizedBox(height: 20,)
              ],

            ),

          ),
        ],
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
                    imageProvider: NetworkImage(eventDetails?['posterUrl']!),
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
            eventDetails?['posterUrl']!,
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
            SizedBox(height: eventDetails?['posterUrl']!=null?16:0),
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
}