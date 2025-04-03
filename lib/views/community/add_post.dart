import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart'; // Add this package for reverse geocoding
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
  bool _isSubmitting = false; // Flag to track submission state

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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_isSubmitting) return; // Prevent multiple submissions

    setState(() {
      _isSubmitting = true; // Disable the submit button
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You must be logged in to post."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSubmitting = false; // Re-enable the submit button
      });
      return;
    }

    if (questionController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter both a question and a description."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSubmitting = false; // Re-enable the submit button
      });
      return;
    }

    String? imageUrl;

    if (_image != null) {
      try {
        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(
            'community_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed: $e"), backgroundColor: Colors.red),
        );
        setState(() {
          _isSubmitting = false; // Re-enable the submit button
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
        'location': _userLocation, // Add the user's location
        'user_name': _userName, // Add the user's name
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post submitted successfully!"), backgroundColor: Colors.green),
      );

      // Clear fields & reset image
      questionController.clear();
      descriptionController.clear();
      setState(() {
        _image = null;
        _isSubmitting = false; // Re-enable the submit button
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post submission failed: $e"), backgroundColor: Colors.red),
      );
      setState(() {
        _isSubmitting = false; // Re-enable the submit button
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ask the Community",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: "Question",
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                style: TextStyle(color: Colors.black),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                style: TextStyle(color: Colors.black),
                maxLines: 5,
              ),
              SizedBox(height: 10),
              _image != null
                  ? Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey, width: 1.5),
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    "No Image Selected",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Pick an Image",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost, // Disable button when submitting
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white) // Show loading indicator
                    : Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}