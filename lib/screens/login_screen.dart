import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../components/responsive_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // <-- AÑADIDO

  bool showRegisterFields = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return; // <-- VALIDACIÓN

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = await authProvider.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return; // <-- VALIDACIÓN

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = await authProvider.signUp(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
    );

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Inicia sesión para continuar.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        showRegisterFields = false;
        nameController.clear();
        emailController.clear();
        passwordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: ResponsiveForm(
        child: Form(
          // <-- AÑADIDO
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showRegisterFields ? 'Regístrate' : 'Bienvenido',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              if (showRegisterFields)
                TextFormField(
                  controller: nameController,
                  validator: Validators.validateName, // <-- VALIDACIÓN
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (showRegisterFields) const SizedBox(height: 12),

              TextFormField(
                controller: emailController,
                validator: Validators.validateEmail, // <-- VALIDACIÓN
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: Validators.validatePassword, // <-- VALIDACIÓN
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),

              if (!showRegisterFields)
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 71, 110, 240),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              if (showRegisterFields)
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 71, 110, 240),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Registrar cuenta',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  setState(() {
                    showRegisterFields = !showRegisterFields;
                  });
                },
                child: Text(
                  showRegisterFields
                      ? '¿Ya tienes cuenta? Inicia sesión'
                      : '¿No tienes cuenta? Regístrate',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
