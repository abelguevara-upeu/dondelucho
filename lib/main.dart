import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'admin/AdminHomeScreen.dart';
import 'admin/AdminCategoryScreen.dart';
import 'provider/cart_provider.dart';
import 'screens/carrito.screen.dart'; // 👈 AÑADIDO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await autoLoginInvitado();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

Future<void> autoLoginInvitado() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      await auth.signInWithEmailAndPassword(
        email: 'invitado@ejemplo.com',
        password: 'invitado123',
      );
      print('✅ Sesión iniciada como invitado');
    } catch (e) {
      print('❌ Error al iniciar sesión como invitado: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/adminHome': (context) => AdminHomeScreen(),
        '/categorias': (context) => AdminCategoryScreen(),
        '/promociones': (context) => Center(child: Text("Promociones Admin")),
        '/pedidos': (context) => Center(child: Text("Pedidos Admin")),
        '/cuenta': (context) => Center(child: Text("Cuenta Admin")),
        '/cart': (context) => const CartScreen(), // ✅ AÑADIDO
      },
    );
  }
}
