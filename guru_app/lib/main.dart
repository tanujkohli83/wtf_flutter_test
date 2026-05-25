import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await SessionLogService.initializeLocalCache();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException {
      // Web may not have anonymous auth enabled in the Firebase project.
    }
  }
  runApp(const ProviderScope(child: MyApp()));
}
