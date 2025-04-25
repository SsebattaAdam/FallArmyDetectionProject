# Fall Armyworm Detection and Management System (fammaize)

A Flutter-based mobile application integrated with a Flask backend to help Ugandan farmers detect, monitor, and manage **Fall Armyworm (Spodoptera frugiperda)** infestations affecting maize crops.

---

## 🌾 Overview

Fall Armyworm is a highly destructive pest that poses a serious threat to maize production in Sub-Saharan Africa. This system leverages machine learning, geolocation, weather data, and community interaction to provide a digital solution for early detection, accurate diagnosis, and guided treatment of infestations.

---

## 📱 Features

### 🔍 Detection
- Upload maize leaf images via camera or gallery.
- Uses TensorFlow Lite model to classify images as:
  - Healthy
  - Eggs
  - Frass
  - Larval Damage
- Confidence score provided for each detection.

### 🌐 Geolocation
- GPS coordinates captured automatically.
- Maps detections to specific Ugandan districts.
- Displays results on an interactive district-level map.

### 📊 Analytics Dashboard
- View district-wise infestation trends.
- Filter data by day, week, month.
- Charts: stage distribution, comparisons, and detection history.

### ☁️ Weather Integration
- Real-time local weather from OpenWeatherMap API.
- Tailors treatment advice based on temperature, rainfall, and humidity.

### 💊 Treatment Recommendations
- Stage-based recommendations for pest control.
- Includes:
  - Pesticide name
  - Application time
  - Mixing ratios
  - Safety guidelines

### 📥 Reports
- Downloadable diagnosis reports per detection.
- Includes image preview, GPS, timestamp, and treatment advice.

### 🧑🏾‍🤝‍🧑🏽 Community Support
- Farmers can describe problems, upload supporting images, and get expert help.
- Experts provide structured replies with guidance.

### 🧠 Detection History
- All past detections stored with timestamp, GPS, and results.

---

## 🧱 System Architecture

- **Frontend:** Flutter mobile application
- **Backend:** Flask REST API
- **ML Model:** TensorFlow Lite (image classification)
- **Database:** SQLite / PostgreSQL
- **Cloud APIs:** OpenWeatherMap, Google Maps

---

## ⚙️ Technical Specifications

| Feature                     | Details                                                              |
|----------------------------|----------------------------------------------------------------------|
| Version Control            | Git with GitHub; branches for `main`, `geo-feature`, `analytics-enhancements` |
| Image Input                | Maize leaf via camera or gallery  , Realtime scanning                                   |
| Output                     | Infestation stage, report, treatment advice                          |
| Location Validation        | Ensures GPS points are within Uganda                                |
| Internet Dependency        | Required for weather, maps, and community support                    |
| Security                   | HTTPS, role-based access, API rate-limiting                         |
| Error Handling             | Human-readable feedback and internal logging                        |

---

## 🚀 Installation & Getting Started

### 📱 Flutter App

```bash
git clone https://github.com/SsebattaAdam/FallArmyDetectionProject/
cd fammaize
flutter pub get
flutter run
