import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Providers
import 'helpers/providers/auth_provider.dart';
import 'helpers/providers/data_provider.dart';
import 'helpers/providers/notification_provider.dart';

// Firebase
import 'firebase_options.dart';

// Theme
import 'app_theme.dart';

// Pantallas principales
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

// Formularios
import 'screens/note_screen.dart';
import 'screens/event_screen.dart';
import 'screens/reminder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase ya estaba inicializado. Continuando.');
    } else {
      rethrow;
    }
  }

  final notificationProvider = NotificationProvider();
  await notificationProvider.initNotifications();
  await notificationProvider.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/noteForm': (context) => const NoteFormScreen(),
        '/eventForm': (context) => const EventFormScreen(),
        '/reminderForm': (context) => const ReminderFormScreen(),
      },
    );
  }
}
