import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app_root.dart';
import 'app/core/config/app_config.dart';
import 'app/core/config/firebase_remote_config_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _systemOrientation();
  await _loadEnv();
  await _initializeFirebase(AppConfig.fromEnvironment());
  final appConfig = await _appConfigEnvironment();
  runApp(AppRoot(appConfig: appConfig));
}

Future<void> _initializeFirebase(AppConfig config) async {
  final options = config.firebaseOptions;
  if (options == null) {
    return;
  }
  if (Firebase.apps.isNotEmpty) {
    return;
  }
  try {
    await Firebase.initializeApp(options: options);
  } catch (error, stackTrace) {
    debugPrint('Firebase.initializeApp failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _systemOrientation() async {
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

Future<void> _loadEnv() async {
  await dotenv.load(fileName: '.env', isOptional: true);
}

Future<AppConfig> _appConfigEnvironment() async {
  final fallbackConfig = AppConfig.fromEnvironment();
  final apiKeyResolution = await FirebaseRemoteConfigRepository(
    config: fallbackConfig,
  ).resolveGemmaApiKey(fetchTimeoutOverride: const Duration(seconds: 2));
  final appConfig = fallbackConfig.copyWith(
    gemmaApiKey: apiKeyResolution.apiKey,
  );

  debugPrint(
    'Startup API key source: '
        '${apiKeyResolution.usedRemoteConfigValue ? 'firebase_remote_config' : 'fallback_env'}',
  );

  return appConfig;
}