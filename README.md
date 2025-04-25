FAM Maize - Fall Armyworm Detection & Management
🌽 About FAM Maize
FAM Maize is a comprehensive mobile application designed to help Ugandan farmers detect, monitor, and manage Fall Armyworm (Spodoptera frugiperda) infestations in maize crops. This destructive pest threatens food security and livelihoods across Sub-Saharan Africa, and early detection is crucial for effective management.

Our solution leverages machine learning, geospatial analysis, and community support to provide timely and accurate detection of Fall Armyworm at various stages of infestation.

✨ Key Features
📱 Screenshots
🛠️ Technology Stack
Frontend: Flutter for cross-platform mobile development
Backend: Flask-based REST API
Machine Learning: TensorFlow Lite for on-device image classification
Geospatial: Google Maps API for location tracking and visualization
Database: Firebase Firestore for data storage
Authentication: Firebase Authentication
Weather Data: OpenWeatherMap API
📋 Requirements
Android 6.0 (Marshmallow) or higher
iOS 12.0 or higher
Internet connection for most features
GPS/Location services enabled
Camera access permission
Storage access permission
🚀 Installation
Download
For Developers
Clone the repository:

git clone https://github.com/yourusername/fam-maize.git
cd fam-maize

Copy
Execute

Install dependencies:

flutter pub get

Copy
Execute

Configure Firebase:

Create a new Firebase project
Add Android and iOS apps to your Firebase project
Download and add the configuration files
Enable Authentication, Firestore, and Storage services
Configure API keys:

Create a .env file in the project root
Add your API keys
Run the application:

flutter run

Copy
Execute

📖 How to Use
Detection Module
Tap the "Detect" button on the home screen
Choose to take a new photo or select from gallery
Ensure the image clearly shows the maize leaf
Submit the image for analysis
View the detection results and recommended treatments
Save or share the detection report
Map Visualization
Navigate to the "Map" tab
View all detections mapped across Uganda
Filter by date range, district, or infestation stage
Tap on markers to view detection details
Analytics Dashboard
Access the "Analytics" section
View infestation trends over time
Compare district-wise statistics
Generate and download reports
Community Support
Go to the "Community" tab
Create a new post with your question or concern
Optionally attach images
Receive responses from experts and other farmers
Search existing discussions for similar issues
