import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'root_screen.dart';
import 'app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.load();
  runApp(const GyuniAriaNoteApp());
}

class GyuniAriaNoteApp extends StatelessWidget {
  const GyuniAriaNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        final brightness = _resolveBrightness();

        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          title: '규니의 아리아 노트♥',
          theme: CupertinoThemeData(
            brightness: brightness,
            primaryColor: CupertinoColors.systemPink,
            scaffoldBackgroundColor: brightness == Brightness.dark
                ? const Color(0xFF000000)
                : const Color(0xFFF2F2F7),
          ),
          home: const RootScreen(),
        );
      },
    );
  }

  Brightness _resolveBrightness() {
    switch (appSettings.themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }
}
