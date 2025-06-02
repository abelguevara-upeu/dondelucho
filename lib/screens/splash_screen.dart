import 'package:flutter/material.dart';
import 'dart:async'; // Para manejar el temporizador
import 'auth_screen.dart'; // Redirige a la pantalla de autenticación

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Redirige a la pantalla de autenticación después de 3 segundos
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imagen_fondo.jpg'), // Imagen del splash
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
