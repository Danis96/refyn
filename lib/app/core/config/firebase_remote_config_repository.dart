import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'app_config.dart';

class RemoteConfigApiKeyResolution {
  const RemoteConfigApiKeyResolution({
    required this.apiKey,
    required this.usedRemoteConfigValue,
  });

  final String apiKey;
  final bool usedRemoteConfigValue;
}

class FirebaseRemoteConfigRepository {
  const FirebaseRemoteConfigRepository({required AppConfig config})
    : _config = config;

  final AppConfig _config;

  Future<RemoteConfigApiKeyResolution> resolveGemmaApiKey({
    Duration? fetchTimeoutOverride,
  }) async {
    final fallbackApiKey = _config.fallbackGemmaApiKey.trim();

    if (!_config.hasFirebaseRemoteConfigSetup) {
      return RemoteConfigApiKeyResolution(
        apiKey: fallbackApiKey,
        usedRemoteConfigValue: false,
      );
    }

    try {
      await _ensureFirebaseInitialized();

      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout:
              fetchTimeoutOverride ?? _config.firebaseRemoteConfigFetchTimeout,
          minimumFetchInterval:
              _config.firebaseRemoteConfigMinimumFetchInterval,
        ),
      );
      await remoteConfig.setDefaults({
        _config.firebaseRemoteConfigGemmaApiKeyParam: fallbackApiKey,
      });

      final activated = await remoteConfig.fetchAndActivate();
      debugPrint(
        'Remote Config fetchAndActivate activated=$activated '
        'lastFetchStatus=${remoteConfig.lastFetchStatus.name} '
        'lastFetchTime=${remoteConfig.lastFetchTime.toIso8601String()}',
      );

      final remoteApiKey = remoteConfig
          .getString(_config.firebaseRemoteConfigGemmaApiKeyParam)
          .trim();
      debugPrint(
        'Remote Config param '
        '${_config.firebaseRemoteConfigGemmaApiKeyParam} '
        'length=${remoteApiKey.length}',
      );

      if (remoteApiKey.isEmpty) {
        return RemoteConfigApiKeyResolution(
          apiKey: fallbackApiKey,
          usedRemoteConfigValue: false,
        );
      }

      return RemoteConfigApiKeyResolution(
        apiKey: remoteApiKey,
        usedRemoteConfigValue: true,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Firebase Remote Config fetch failed, using fallback Gemma API key: '
        '$error',
      );
      debugPrintStack(stackTrace: stackTrace);
      return RemoteConfigApiKeyResolution(
        apiKey: fallbackApiKey,
        usedRemoteConfigValue: false,
      );
    }
  }

  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    final firebaseOptions = _config.firebaseOptions;
    if (firebaseOptions == null) {
      return;
    }

    await Firebase.initializeApp(options: firebaseOptions);
  }
}
