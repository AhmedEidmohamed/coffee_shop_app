# coffee_shop_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase setup

- This project supports Firebase Authentication, but it ships with a **local fake auth** fallback so you can run and test sign up / sign in without configuring Firebase.
- To enable real Firebase, run:
  - `dart pub global activate flutterfire_cli`
  - `flutterfire configure`
  This will generate `lib/firebase_options.dart` with `DefaultFirebaseOptions` and set `firebaseConfigured = true`.
- After configuring, enable **Email/Password** in the Firebase Console Authentication section.
