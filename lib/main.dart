import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Providers
import 'helpers/providers/auth_provider.dart';
import 'helpers/providers/data_provider.dart';

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

// Services
import 'helpers/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('⚠️ Firebase ya estaba inicializado. Continuando.');
    } else {
      rethrow;
    }
  }

  // Inicializar notificaciones (nuevo)
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('❌ Error inicializando notificaciones: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return MaterialApp(
      title: 'Mi Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Redirige si hay sesión activa
      home: auth.currentUser == null ? const LoginScreen() : const HomeScreen(),

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
