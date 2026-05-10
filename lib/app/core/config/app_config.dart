import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({
    required this.gemmaApiKey,
    required this.fallbackGemmaApiKey,
    required this.gemmaModel,
    required this.gemmaApiBaseUrl,
    required this.firebaseApiKey,
    required this.firebaseAndroidApiKey,
    required this.firebaseIosApiKey,
    required this.firebaseProjectId,
    required this.firebaseMessagingSenderId,
    required this.firebaseAndroidAppId,
    required this.firebaseIosAppId,
    required this.firebaseStorageBucket,
    required this.firebaseIosBundleId,
    required this.firebaseRemoteConfigGemmaApiKeyParam,
    required this.firebaseRemoteConfigFetchTimeoutSeconds,
    required this.firebaseRemoteConfigMinimumFetchIntervalSeconds,
  });

  factory AppConfig.fromEnvironment({String? gemmaApiKeyOverride}) {
    Map<String, String> env;

    try {
      env = dotenv.env;
    } catch (_) {
      env = const {};
    }

    final fallbackGemmaApiKey = env['GEMMA_API_KEY'] ?? '';

    return AppConfig(
      gemmaApiKey: gemmaApiKeyOverride ?? fallbackGemmaApiKey,
      fallbackGemmaApiKey: fallbackGemmaApiKey,
      gemmaModel: env['GEMMA_MODEL'] ?? 'gemma-4-26b-a4b-it',
      gemmaApiBaseUrl:
          env['GEMMA_API_BASE_URL'] ??
          'https://generativelanguage.googleapis.com/v1beta',
      firebaseApiKey: env['FIREBASE_API_KEY'] ?? '',
      firebaseAndroidApiKey:
          env['FIREBASE_ANDROID_API_KEY'] ??
          env['FIREBASE_API_KEY'] ??
          '',
      firebaseIosApiKey:
          env['FIREBASE_IOS_API_KEY'] ??
          env['FIREBASE_API_KEY'] ??
          '',
      firebaseProjectId: env['FIREBASE_PROJECT_ID'] ?? '',
      firebaseMessagingSenderId: env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      firebaseAndroidAppId: env['FIREBASE_ANDROID_APP_ID'] ?? '',
      firebaseIosAppId: env['FIREBASE_IOS_APP_ID'] ?? '',
      firebaseStorageBucket: env['FIREBASE_STORAGE_BUCKET'] ?? '',
      firebaseIosBundleId: env['FIREBASE_IOS_BUNDLE_ID'] ?? '',
      firebaseRemoteConfigGemmaApiKeyParam:
          env['FIREBASE_REMOTE_CONFIG_GEMMA_API_KEY_PARAM'] ??
          'gemma_api_key',
      firebaseRemoteConfigFetchTimeoutSeconds:
          int.tryParse(
            env['FIREBASE_REMOTE_CONFIG_FETCH_TIMEOUT_SECONDS'] ?? '',
          ) ??
          10,
      firebaseRemoteConfigMinimumFetchIntervalSeconds:
          int.tryParse(
            env['FIREBASE_REMOTE_CONFIG_MINIMUM_FETCH_INTERVAL_SECONDS'] ?? '',
          ) ??
          0,
    );
  }

  final String gemmaApiKey;
  final String fallbackGemmaApiKey;
  final String gemmaModel;
  final String gemmaApiBaseUrl;
  final String firebaseApiKey;
  final String firebaseAndroidApiKey;
  final String firebaseIosApiKey;
  final String firebaseProjectId;
  final String firebaseMessagingSenderId;
  final String firebaseAndroidAppId;
  final String firebaseIosAppId;
  final String firebaseStorageBucket;
  final String firebaseIosBundleId;
  final String firebaseRemoteConfigGemmaApiKeyParam;
  final int firebaseRemoteConfigFetchTimeoutSeconds;
  final int firebaseRemoteConfigMinimumFetchIntervalSeconds;

  bool get hasGemmaApiKey => gemmaApiKey.trim().isNotEmpty;

  bool get hasFallbackGemmaApiKey => fallbackGemmaApiKey.trim().isNotEmpty;

  Duration get firebaseRemoteConfigFetchTimeout =>
      Duration(seconds: firebaseRemoteConfigFetchTimeoutSeconds);

  Duration get firebaseRemoteConfigMinimumFetchInterval =>
      Duration(seconds: firebaseRemoteConfigMinimumFetchIntervalSeconds);

  bool get hasFirebaseRemoteConfigSetup =>
      firebaseRemoteConfigGemmaApiKeyParam.trim().isNotEmpty &&
      firebaseOptions != null;

  FirebaseOptions? get firebaseOptions {
    if (kIsWeb) {
      return null;
    }

    final appId = switch (defaultTargetPlatform) {
      TargetPlatform.android => firebaseAndroidAppId.trim(),
      TargetPlatform.iOS => firebaseIosAppId.trim(),
      _ => '',
    };
    final apiKey = switch (defaultTargetPlatform) {
      TargetPlatform.android => firebaseAndroidApiKey.trim(),
      TargetPlatform.iOS => firebaseIosApiKey.trim(),
      _ => firebaseApiKey.trim(),
    };

    if (appId.isEmpty ||
        apiKey.isEmpty ||
        firebaseProjectId.trim().isEmpty ||
        firebaseMessagingSenderId.trim().isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: firebaseMessagingSenderId,
      projectId: firebaseProjectId,
      storageBucket: firebaseStorageBucket.trim().isEmpty
          ? null
          : firebaseStorageBucket,
      iosBundleId:
          defaultTargetPlatform == TargetPlatform.iOS &&
                  firebaseIosBundleId.trim().isNotEmpty
              ? firebaseIosBundleId
              : null,
    );
  }

  AppConfig copyWith({String? gemmaApiKey}) {
    return AppConfig(
      gemmaApiKey: gemmaApiKey ?? this.gemmaApiKey,
      fallbackGemmaApiKey: fallbackGemmaApiKey,
      gemmaModel: gemmaModel,
      gemmaApiBaseUrl: gemmaApiBaseUrl,
      firebaseApiKey: firebaseApiKey,
      firebaseAndroidApiKey: firebaseAndroidApiKey,
      firebaseIosApiKey: firebaseIosApiKey,
      firebaseProjectId: firebaseProjectId,
      firebaseMessagingSenderId: firebaseMessagingSenderId,
      firebaseAndroidAppId: firebaseAndroidAppId,
      firebaseIosAppId: firebaseIosAppId,
      firebaseStorageBucket: firebaseStorageBucket,
      firebaseIosBundleId: firebaseIosBundleId,
      firebaseRemoteConfigGemmaApiKeyParam:
          firebaseRemoteConfigGemmaApiKeyParam,
      firebaseRemoteConfigFetchTimeoutSeconds:
          firebaseRemoteConfigFetchTimeoutSeconds,
      firebaseRemoteConfigMinimumFetchIntervalSeconds:
          firebaseRemoteConfigMinimumFetchIntervalSeconds,
    );
  }
}
