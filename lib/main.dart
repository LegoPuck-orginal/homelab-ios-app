import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/sensor_provider.dart';
import 'providers/services_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/adobe_colors.dart';
import 'theme/adobe_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // OLED-optimierte Statusleiste konfigurieren
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AdobeColors.pureBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SensorProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServicesProvider()..initialize(),
        ),
      ],
      child: const HomelabCoreApp(),
    ),
  );
}

class HomelabCoreApp extends StatelessWidget {
  const HomelabCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homelab // Core',
      debugShowCheckedModeBanner: false,
      theme: AdobeTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
