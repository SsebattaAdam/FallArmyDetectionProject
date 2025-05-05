import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _image;
  String? _userLocation;
  String? _userName;
  bool _isSubmitting = false;

  // Define green color constants
  final Color primaryGreen = Color(0xFF2E7D32); // Dark green
  final Color lightGreen = Color(0xFFE8F5E9); // Light green background
  final Color mediumGreen = Color(0xFF81C784); // Medium green for accents

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final latLong = userDoc['location'].split(', ');
        final lat = double.parse(latLong[0].split(': ')[1]);
        final long = double.parse(latLong[1].split(': ')[1]);
        // Reverse geocoding to get the exact location
        final placemarks = await placemarkFromCoordinates(lat, long);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          setState(() {
            _userLocation = "${placemark.locality}, ${placemark.country}";
            _userName = userDoc['name']; // Fetch the user's name
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compress image for faster uploads
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You must be logged in to post."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    if (questionController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter both a question and a description."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    String? imageUrl;
    if (_image != null) {
      try {
        // Show uploading progress
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text("Uploading image..."),
              ],
            ),
            duration: Duration(seconds: 10),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(
            'community_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();

        // Dismiss the uploading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image upload failed: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }
    }

    try {
      // Save post data in Firestore
      await FirebaseFirestore.instance.collection('community_posts').add({
        'question': questionController.text,
        'description': descriptionController.text,
        'image_url': imageUrl,
        'location': _userLocation,
        'user_name': _userName,
        'authorId': user.uid,
        'authorName': user.displayName ?? _userName ?? 'Anonymous',
        'authorPhotoUrl': user.photoURL,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Post submitted successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Clear fields & reset image
      questionController.clear();
      descriptionController.clear();
      setState(() {
        _image = null;
        _isSubmitting = false;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Post submission failed: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Ask the Community",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: primaryGreen,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Container(
        color: lightGreen.withOpacity(0.3),
    child: Padding(
    padding: EdgeInsets.all(16.0),
    child: SingleChildScrollView(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Location indicator
    if (_userLocation != null)
    Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: primaryGreen.withOpacity(0.3)),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 2,
    offset: Offset(0, 1),
    ),
    ],
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    Icons.location_on,
    size: 16,
    color: primaryGreen,
    ),
    SizedBox(width: 8),
    Text(
    "Posting from: $_userLocation",
    style: TextStyle(
    color: Colors.grey[700],
    fontSize: 14,
    ),
    ),
    ],
    ),
    ),

    // Question field
    Container(
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 5,
    offset: Offset(0, 2),
    ),
    ],
    ),
    child: TextField(
    controller: questionController,
    decoration: InputDecoration(
    labelText: "Question",
    labelStyle: TextStyle(color: primaryGreen),
    hintText: "What would you like to ask the community?",
    hintStyle: TextStyle(color: Colors.grey),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: primaryGreen, width: 2.0),
    borderRadius: BorderRadius.circular(12.0),
    ),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: primaryGreen.withOpacity(0.5), width: 1.5),
    borderRadius: BorderRadius.circular(12.0),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.all(16),
    ),
    style: TextStyle(color: Colors.black87, fontSize: 16),
    maxLines: 3,
    ),
    ),

    SizedBox(height: 16),

    // Description field
    Container(
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 5,
    offset: Offset(0, 2),
    ),
    ],
    ),
    child: TextField(
    controller: descriptionController,
    decoration: InputDecoration(
    labelText: "Description",
    labelStyle: TextStyle(color: primaryGreen),
    hintText: "Provide more details about your question...",
    hintStyle: TextStyle(color: Colors.grey),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: primaryGreen, width: 2.0),
    borderRadius: BorderRadius.circular(12.0),
    ),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: primaryGreen.withOpacity(0.5), width: 1.5),
    borderRadius: BorderRadius.circular(12.0),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.all(16),
    ),
    style: TextStyle(color: Colors.black87, fontSize: 16),
    maxLines: 5,
    ),
    ),

    SizedBox(height: 20),

    // Image preview
    Container(
    width: double.infinity,
    height: 250,
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    border: Border.all(color: primaryGreen.withOpacity(0.5), width: 1.5),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 5,
    offset: Offset(0, 2),
    ),
    ],
    ),
    child: _image != null
    ? ClipRRect(
    borderRadius: BorderRadius.circular(10.0),
    child: Stack(
    fit: StackFit.expand,
    children: [
    Image.file(
    _image!,
    fit: BoxFit.cover,
    ),
    Positioned(
    top: 8,
    right: 8,
    child: GestureDetector(
    onTap: () {
    setState(() {
    _image = null;
    });
    },
    child: Container(
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.6),
    shape: BoxShape.circle,
    ),
    child: Icon(
    Icons.close,
    color: Colors.white,
    size: 20,
    ),
    ),
    ),
    ),
    ],
    ),
    )
        : Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.image,
    size: 64,
    color: Colors.grey[400],
    ),
    SizedBox(height: 12),
    Text(
    "No Image Selected",
    style: TextStyle(
    color: Colors.grey[600],
    fontSize: 16,
    ),
    ),
    SizedBox(height: 8),
    Text(
    "Tap the button below to add an image",
    style: TextStyle(
    color: Colors.grey[500],
    fontSize: 14,
    ),
    ),
    ],
    ),
    ),

    SizedBox(height: 16),

    // Pick image button
    ElevatedButton.icon(
    onPressed: _pickImage,
    icon: Icon(Icons.photo_library),
    label: Text("Select Image"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: primaryGreen,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: primaryGreen, width: 1.5),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    ),

      SizedBox(height: 24),

      // Submit button
      Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primaryGreen.withOpacity(0.6),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Submitting...",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded),
              SizedBox(width: 8),
              Text(
                "Submit Post",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),

      SizedBox(height: 16),

      // Guidelines
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Community Guidelines",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryGreen,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            _buildGuidelineItem(
              "Be respectful to other community members",
              Icons.people_outline,
            ),
            _buildGuidelineItem(
              "Share relevant and helpful information",
              Icons.info_outline,
            ),
            _buildGuidelineItem(
              "Avoid posting personal or sensitive information",
              Icons.privacy_tip_outlined,
            ),
          ],
        ),
      ),

      SizedBox(height: 40),
    ],
    ),
    ),
    ),
        ),
    );
  }

  Widget _buildGuidelineItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: primaryGreen.withOpacity(0.7),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

