import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sun_envidiado_website/app/app.dart';
import 'package:sun_envidiado_website/firebase_options.dart';

void main() {
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureFirebase();
    _configureFontLicenses();
    runApp(const App());
  });
}

void _configureFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/fonts/ibm_vga_8/LICENSE.txt',
    );
    yield LicenseEntryWithLineBreaks(['IBM VGA 8'], license);
  });
}

Future<void> _configureFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }
}
