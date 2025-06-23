import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

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
          icon: Icon(Icons.shopping_bag),
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
        if (index == 1) {
          final user = FirebaseAuth.instance.currentUser;

          String role = 'cliente'; // por defecto

          if (user != null) {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            if (userDoc.exists && userDoc.data()!.containsKey('role')) {
              role = userDoc['role'];
            }
          }

          // ✅ Solo cambiar índice, no hacer push
          if (role == 'cliente') {
            onTap(index); // muestra CategoriasScreen desde el IndexedStack
          } else {
            // si fuera admin, podrías cambiar de lógica si lo necesitas
            onTap(index); // igual mantenemos el índice
          }
        } else {
          onTap(index);
        }
      },
    );
  }
}
