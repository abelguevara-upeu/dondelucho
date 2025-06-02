import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import '../screens/categorias_screen.dart'; // Vista del cliente
import '../admin/AdminCategoryScreen.dart'; // Vista del administrador

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Categorías',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          label: 'Promociones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag), // Ícono de pedidos
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Cuenta',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.grey,
      onTap: (index) async {
        if (index == 1) { // Categorías
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

            if (userDoc.exists) {
              final role = userDoc['role'];
              if (role == 'administrador') {
                // Navega a AdminCategoryScreen directamente
                onTap(index); // Cambia el índice del `CustomBottomNavBar`
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminCategoryScreen()),
                );
              } else {
                // Navega a CategoriasScreen directamente como cliente
                onTap(index); // Cambia el índice del `CustomBottomNavBar`
              }
            }
          }
        } else {
          onTap(index); // Ejecuta el callback para los otros índices
        }
      },
    );
  }
}
