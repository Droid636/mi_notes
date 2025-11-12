import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

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

  // ✅ INICIALIZACIÓN DE FIREBASE CON BLOQUE TRY-CATCH
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Si el error es una aplicación duplicada, la ignoramos
    // y permitimos que la aplicación continúe con la instancia existente.
    if (e.toString().contains('duplicate-app')) {
      print('Firebase ya estaba inicializado. Continuando.');
    } else {
      // Si es otro error crítico, lo relanzamos.
      rethrow;
    }
  }

  // ✅ INICIALIZAR NOTIFICACIONES (local + Firebase Messaging)
  final notificationProvider = NotificationProvider();
  await notificationProvider.initNotifications();
  await notificationProvider.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider (no extiende ChangeNotifier)
        Provider(create: (_) => AuthProvider()),

        // DataProvider (sí extiende ChangeNotifier)
        ChangeNotifierProvider(create: (_) => DataProvider()),

        // NotificationProvider (para notificaciones locales y push)
        ChangeNotifierProvider<NotificationProvider>(create: (_) => notificationProvider),
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
      
      // ✅ TEMAS LIGHT Y DARK CONFIGURADOS
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
