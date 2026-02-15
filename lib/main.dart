import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/repository/authentication_repository/authentication_repository.dart';
import 'firebase_options.dart';

/// ------ For Docs & Updates Check ------
/// ------------- README.md --------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// -- README(Update[]) -- GetX Local Storage
  await GetStorage.init();

  /// YOUR SUPABASE KEY ID HERE
  await Supabase.initialize(url: '', anonKey: '');

  /// -- README(Docs[2]) -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) => Get.put(AuthenticationRepository()));

  /// -- Main App Starts here (app.dart) ...
  runApp(const App());
}
