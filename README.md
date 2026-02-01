
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/c760c0ee-d768-47ca-b87b-d6b7c91cd16c" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/e2a7d0bf-da2e-40be-b70b-30d52be1f6a2" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/e457313a-fd9c-4e04-aa27-02538b161597" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/2be18aed-07d6-4332-936b-a06cf0698903" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/0f1e3ee4-9329-46ce-b172-a600ff870c48" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/f1f1039a-2067-44c8-bbb4-29b304388795" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/5f612183-ef97-40b0-909a-29b5a1bb3b1d" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/b80e66be-d15b-43f5-a93c-5024cce99228" />







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
