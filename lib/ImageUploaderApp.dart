import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUploaderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloudinary Image Upload',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: UploadImagePage(),
    );
  }
}

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _copyUrlToClipboard() {
    if (_uploadedImageUrl != null) {
      Clipboard.setData(ClipboardData(text: _uploadedImageUrl!));
      _showSuccessSnackBar('URL copied to clipboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Cloudinary Uploader',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        actions: [
          if (_uploadedImageUrl != null)
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: _copyUrlToClipboard,
              tooltip: 'Copy URL',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
              child: Padding(
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
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Error: $_errorMessage',
                          style: TextStyle(color: Colors.red[800], fontSize: 14),
                        ),
                      ),

                    if (_uploadedImageUrl != null)
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.indigo.withOpacity(0.2)
                              : Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.indigo.withOpacity(0.3)
                                : Colors.indigo.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cloudinary URL:',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _uploadedImageUrl!,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImageContainer() {
    return Stack(
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
              'Uploaded to Cloudinary',
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
            SizedBox(height: 16),
            Text(
              'No image selected',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap a button below to select an image',
              style: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}