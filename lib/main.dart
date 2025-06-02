import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'admin/AdminHomeScreen.dart';
import 'admin/AdminCategoryScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Mantener el SplashScreen como pantalla inicial
      routes: {
        '/adminHome': (context) => AdminHomeScreen(), // Ruta para la pantalla principal del administrador
        '/categorias': (context) => AdminCategoryScreen(), // Ruta para categorías del administrador
        '/promociones': (context) => Center(child: Text("Promociones Admin")), // Ruta para promociones (placeholder)
        '/pedidos': (context) => Center(child: Text("Pedidos Admin")), // Ruta para pedidos (placeholder)
        '/cuenta': (context) => Center(child: Text("Cuenta Admin")), // Ruta para cuenta (placeholder)
      },
    );
  }
}
