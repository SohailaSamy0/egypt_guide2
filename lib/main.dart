import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Text;

import 'app/app.dart';
import 'core/settings/app_settings_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform,
  );

  await AppSettingsController.instance
      .loadSettings();

  runApp(
    const EgyptGuideApp(),
  );
}