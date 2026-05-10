import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app_root.dart';
import 'app/core/config/app_config.dart';
import 'app/core/config/firebase_remote_config_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  await dotenv.load(fileName: '.env', isOptional: true);

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

  runApp(AppRoot(appConfig: appConfig));
}
