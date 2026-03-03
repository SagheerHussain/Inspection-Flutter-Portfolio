# OtoBix Inspection App

Vehicle inspection management application built with Flutter.

## Getting Started

This project is a Flutter application for managing vehicle inspections.

### Prerequisites
- Flutter SDK ^3.7.2
- Dart SDK
- Android Studio / Xcode

### Setup

1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase (see below)
4. Run `flutter run`

### Firebase Configuration

1. Install Firebase CLI:
   ```shell
   npm install -g firebase-tools
   ```

2. Log in and select your project:
   ```shell
   firebase login
   firebase use --add
   ```

3. Configure FlutterFire:
   ```shell
   flutterfire configure
   ```

### SHA Keys (Android)

**Mac/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Windows:**
```bash
keytool -list -v -keystore "C:\Users\YourPC\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Add output SHA1/SHA256 to Firebase Project Settings > Your App.

### Build

**Android (AAB):**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### Cloud Functions Deployment

```shell
cd functions
npm install
firebase deploy --only functions
```

## App Details

- **App Name:** OtoBix Inspection App
- **Package Name:** com.otobix.inspectionapp
- **Platform:** Android & iOS