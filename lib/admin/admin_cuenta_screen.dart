import 'package:flutter/material.dart';
import 'AdminReservasScreen.dart';
class AdminCuentaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuenta Administrador'),
        backgroundColor: Colors.brown,
      ),
      body: AdminReservasScreen(), // 👈 Muestra directamente la lista de reservas
    );
  }
}
