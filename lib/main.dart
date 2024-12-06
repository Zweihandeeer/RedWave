import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:RedWave/services/audio_service.dart';
import 'package:RedWave/services/data_manager.dart';
import 'package:RedWave/services/logger_service.dart';
import 'package:RedWave/services/router_service.dart';
import 'package:RedWave/services/settings_manager.dart';
import 'package:RedWave/style/app_themes.dart';

late RedWaveAudioHandler audioHandler;

final logger = Logger();

bool isFdroidBuild = false;
bool isUpdateChecked = false;

final appLanguages = <String, String>{
  'English': 'en',
  'Spanish': 'es'
};

final appSupportedLocales = appLanguages.values
    .map((languageCode) => Locale.fromSubtags(languageCode: languageCode))
    .toList();

class RedWave extends StatefulWidget {
  const RedWave({super.key});

  static Future<void> updateAppState(
    BuildContext context, {
    ThemeMode? newThemeMode,
    Locale? newLocale,
    Color? newAccentColor,
    bool? useSystemColor,
  }) async {
    context.findAncestorStateOfType<_RedWaveState>()!.changeSettings(
          newThemeMode: newThemeMode,
          newLocale: newLocale,
          newAccentColor: newAccentColor,
          systemColorStatus: useSystemColor,
        );
  }

  @override
  _RedWaveState createState() => _RedWaveState();
}

class _RedWaveState extends State<RedWave> {
  void changeSettings({
    ThemeMode? newThemeMode,
    Locale? newLocale,
    Color? newAccentColor,
    bool? systemColorStatus,
  }) {
    setState(() {
      if (newThemeMode != null) {
        themeMode = newThemeMode;
        brightness = getBrightnessFromThemeMode(newThemeMode);
      }
      if (newLocale != null) {
        languageSetting = newLocale;
      }
      if (newAccentColor != null) {
        if (systemColorStatus != null &&
            useSystemColor.value != systemColorStatus) {
          useSystemColor.value = systemColorStatus;
          addOrUpdateData(
            'settings',
            'useSystemColor',
            systemColorStatus,
          );
        }
        primaryColorSetting = newAccentColor;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Some people said that Colors.transparent causes some issues, so better to use it this way
    final trickyFixForTransparency = Colors.black.withOpacity(0.002);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: trickyFixForTransparency,
        systemNavigationBarColor: trickyFixForTransparency,
      ),
    );

    try {
      LicenseRegistry.addLicense(() async* {
        final license =
            await rootBundle.loadString('assets/licenses/paytone.txt');
        yield LicenseEntryWithLineBreaks(['paytoneOne'], license);
      });
    } catch (e, stackTrace) {
      logger.log('License Registration Error', e, stackTrace);
    }
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        final colorScheme =
        getAppColorScheme(lightColorScheme, darkColorScheme);

        return MaterialApp.router(
          themeMode: themeMode,
          darkTheme: getAppTheme(colorScheme),
          debugShowCheckedModeBanner: false,
          theme: getAppTheme(colorScheme),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: appSupportedLocales,
          locale: languageSetting,
          routerConfig: NavigationManager.router,
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialisation();

  runApp(const RedWave());
}

Future<void> initialisation() async {
  try {
    await Hive.initFlutter();

    final boxNames = ['settings', 'user', 'userNoBackup', 'cache'];

    for (final boxName in boxNames) {
      await Hive.openBox(boxName);
    }

    audioHandler = await AudioService.init(
      builder: RedWaveAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.redwave.redwaveproject',
        androidNotificationChannelName: 'RedWave',
        androidNotificationIcon: 'drawable/ic_launcher_foreground',
        androidShowNotificationBadge: true,
      ),
    );

    // Init router
    NavigationManager.instance;
  } catch (e, stackTrace) {
    logger.log('Initialization Error', e, stackTrace);
  }
}
