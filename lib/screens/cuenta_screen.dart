import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CuentaScreen extends StatefulWidget {
  @override
  _CuentaScreenState createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen> {
  String? nombre;
  String? apellido;
  String? telefono;
  String? direccion;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      setState(() {
        nombre = data?['nombre'] ?? '';
        apellido = data?['apellido'] ?? '';
        telefono = data?['telefono'] ?? '';
        direccion = data?['direccion'] ?? '';
      });
    }
  }

  Future<void> editarCampo(String titulo, String campo, String? valorInicial) async {
    final controlador = TextEditingController(text: valorInicial);
    final user = FirebaseAuth.instance.currentUser;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controlador,
          decoration: InputDecoration(labelText: campo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (user != null) {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                  campo.toLowerCase(): controlador.text,
                });
                cargarDatosUsuario();
              }
              Navigator.pop(context);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> confirmarEliminacionCuenta() async {
    final user = FirebaseAuth.instance.currentUser;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Cuenta'),
        content: Text('¿Estás seguro que deseas eliminar tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (user != null) {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                await user.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cuenta Eliminada')),
                );
              }
              Navigator.pop(context);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi cuenta'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (user != null) ...[
            Text('${nombre ?? ''} ${apellido ?? ''}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(user.email ?? '', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            buildBoton('Nombre y Apellido', () => editarCampo('Editar Nombre y Apellido', 'nombre', nombre)),
            buildBoton('Número de telefono', () => editarCampo('Editar Número de telefono', 'telefono', telefono)),
            buildBoton('Direcciones de entrega', () => editarCampo('Dirección', 'direccion', direccion)),
            buildBoton('Libro de reclamaciones', () {}),
            buildBoton('Eliminar Cuenta', confirmarEliminacionCuenta),
            buildBoton('Cerrar Sesión', () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            }, color: Colors.grey.shade300),
          ]
        ],
      ),
    );
  }

  Widget buildBoton(String texto, VoidCallback onTap, {Color? color}) {
    return Card(
      child: ListTile(
        title: Text(texto),
        trailing: Icon(Icons.arrow_forward_ios),
        tileColor: color,
        onTap: onTap,
      ),
    );
  }
} 
