import 'dart:developer' as developer;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/core/theme/app_theme.dart';
import 'package:watch2earn/features/settings/providers/theme_provider.dart';
import 'package:watch2earn/routes.dart';

import 'features/home/providers/home_provider.dart';
import 'features/movies/models/movie.dart';
import 'features/movies/models/movie.g.dart';
import 'features/tv_shows/models/season.dart';
import 'features/tv_shows/models/season.g.dart.dart';
import 'features/tv_shows/models/tv_show.dart';
import 'features/tv_shows/models/tv_show.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Get Hive boxes
  final moviesBox = await Hive.openBox<Movie>(AppConstants.moviesBox);
  final tvShowsBox = await Hive.openBox<TvShow>(AppConstants.tvShowsBox);
  final seasonsBox = await Hive.openBox<Season>(AppConstants.seasonBox);

  runApp(
    ProviderScope(
      overrides: [
        // Override Hive box providers with actual boxes
        movieBoxProvider.overrideWithValue(moviesBox),
        tvShowBoxProvider.overrideWithValue(tvShowsBox),
        seasonBoxProvider.overrideWithValue(seasonsBox),
      ],
      child: EasyLocalization(
        supportedLocales: AppConstants.supportedLocales,
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

// Tüm servisleri başlatan fonksiyon
Future<void> _initializeServices() async {
  try {
    // dotenv yükleme
    await dotenv.load(fileName: '.env');
    developer.log("Dotenv yüklendi", name: "Initialization");

    // Test için env değerlerini logla (debug modunda)
    _logAdMobEnvValues();
  } catch (e) {
    developer.log("Dotenv yüklenirken hata: $e", name: "Initialization", error: e);
  }

  try {
    // Hive başlatma
    await Hive.initFlutter();

    // Register Hive adapters
    Hive.registerAdapter(MovieAdapter());
    Hive.registerAdapter(TvShowAdapter());
    Hive.registerAdapter(SeasonAdapter());

    // Hive boxları açma
    await Hive.openBox<Movie>(AppConstants.favoriteMoviesBox);
    await Hive.openBox<Movie>(AppConstants.watchlistMoviesBox);
    await Hive.openBox<TvShow>(AppConstants.favoriteTvShowsBox);
    await Hive.openBox<TvShow>(AppConstants.watchlistTvShowsBox);

    developer.log("Hive başarıyla başlatıldı", name: "Initialization");
  } catch (e) {
    developer.log("Hive başlatılırken hata: $e", name: "Initialization", error: e);
  }

  try {
    // EasyLocalization başlatma
    await EasyLocalization.ensureInitialized();
    developer.log("Lokalizasyon başarıyla başlatıldı", name: "Initialization");
  } catch (e) {
    developer.log("Lokalizasyon başlatılırken hata: $e", name: "Initialization", error: e);
  }

  try {
    // Google Mobile Ads SDK'sını başlat
    await _initializeAdMob();
  } catch (e) {
    developer.log("AdMob başlatılırken hata: $e", name: "Initialization", error: e);
    // Hatayı yut, uygulama reklamsız çalışsın
  }
}

// AdMob'u başlatan fonksiyon
Future<void> _initializeAdMob() async {
  try {
    developer.log('MobileAds initialization başlatılıyor...', name: 'AdMobInit');

    // SDK'nın durumunu kontrol et
    final initStatus = await MobileAds.instance.initialize();

    // SDK durumunu logla
    final statusMap = <String, String>{};
    initStatus.adapterStatuses.forEach((key, value) {
      statusMap[key] = '${value.state.name} - ${value.description}';
    });

    developer.log('AdMob başlatma durumu: $statusMap', name: 'AdMobInit');

    // Test cihazları yapılandırması
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        testDeviceIds: [
          'EMULATOR', // Emülatörler için
          // Gerçek cihaz test ID'lerini buraya ekleyin
        ],
      ),
    );

    developer.log('Google Mobile Ads SDK başarıyla başlatıldı', name: 'AdMobInit');
  } catch (e) {
    developer.log('Google Mobile Ads SDK başlatılırken hata: $e', name: 'AdMobInit', error: e);
    rethrow; // Ana hata işlemeye devret
  }
}

// Env değerlerini logla (debug için)
void _logAdMobEnvValues() {
  const adMobKeys = [
    'ADMOB_BANNER_ID_TEST',
    'ADMOB_INTERSTITIAL_ID_TEST',
    'ADMOB_REWARDED_ID_TEST',
    'ADMOB_BANNER_ID',
    'ADMOB_INTERSTITIAL_ID',
    'ADMOB_REWARDED_ID',
  ];

  for (final key in adMobKeys) {
    final value = dotenv.env[key];
    developer.log('$key: ${value ?? "tanımlanmamış"}', name: 'EnvConfig');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Watch2Earn',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
    );
  }
}