# 🩺 Find Your Doctor

A cross-platform Flutter application designed to help users search for medical specialists, view doctor profiles, and manage appointments seamlessly on Web and Android.

---

## 🚀 Features

* **Doctor Search & Filtering:** Search doctors by specialty, ratings, or location.
* **Appointment Booking:** Seamless user interface for selecting available time slots and scheduling visits.
* **Cross-Platform:** Single codebase running smoothly on both Web and Mobile devices.
* **Automated CI/CD:** Integrated Continuous Integration and Deployment powered by GitHub Actions.

---

## 🛠️ Tech Stack & Tools

* **Frontend:** Flutter & Dart
* **Hosting:** Firebase Hosting (for Web)
* **CI/CD:** GitHub Actions
* **Version Control:** Git & GitHub

---

## 🏗️ Project Structure

```text
find-your-doctor/
├── android/               # Native Android configuration & build files
├── web/                   # Web-specific configurations
├── lib/                   # Application source code
│   ├── models/            # Data structures
│   ├── screens/           # UI components & screens
│   └── services/          # API & business logic
├── test/                  # Automated Unit & Widget tests
│   ├── unit_test.dart
│   └── widget_test.dart
├── .github/
│   └── workflows/
│       └── deploy.yml     # CI/CD Workflow configuration
├── pubspec.yaml           # Flutter dependencies & assets
└── README.md