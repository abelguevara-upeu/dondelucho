import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminPlatosScreen extends StatefulWidget {
  final String categoryName;

  const AdminPlatosScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  _AdminPlatosScreenState createState() => _AdminPlatosScreenState();
}

class _AdminPlatosScreenState extends State<AdminPlatosScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _preguntaController = TextEditingController();
  final TextEditingController _opcionController = TextEditingController();
  File? _selectedImage;
  final picker = ImagePicker();
  final List<Map<String, dynamic>> _preguntas = [];
  final List<String> _opciones = [];

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
    }
  }

  void _agregarOpcion() {
    if (_opcionController.text.isNotEmpty) {
      setState(() {
        _opciones.add(_opcionController.text.trim());
        _opcionController.clear();
      });
    }
  }

  void _agregarPregunta() {
    if (_preguntaController.text.isNotEmpty && _opciones.isNotEmpty) {
      setState(() {
        _preguntas.add({
          "pregunta": _preguntaController.text.trim(),
          "opciones": List.from(_opciones)
        });
        _preguntaController.clear();
        _opciones.clear();
      });
    }
  }

  Future<void> _addPlato() async {
    if (_nombreController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _precioController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debe completar todos los campos y seleccionar una imagen.")),
      );
      return;
    }

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('platos/${widget.categoryName}/$fileName');

    try {
      await storageRef.putFile(_selectedImage!);
      String imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('platos').add({
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio': double.parse(_precioController.text.trim()),
        'imagen': imageUrl,
        'categoria': widget.categoryName,
        'preguntas': _preguntas,
        'disponible': true, // 👈 agregado por defecto
      });

      setState(() {
        _nombreController.clear();
        _descripcionController.clear();
        _precioController.clear();
        _preguntaController.clear();
        _selectedImage = null;
        _preguntas.clear();
        _opciones.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plato agregado correctamente.")),
      );
    } catch (e) {
      print("Error al agregar plato: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al agregar el plato.")),
      );
    }
  }

  Future<void> _deletePlato(String docId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('platos').doc(docId).delete();
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plato eliminado correctamente.")),
      );
    } catch (e) {
      print("Error al eliminar plato: $e");
    }
  }

  Future<void> _toggleDisponible(String docId, bool actual) async {
    try {
      await FirebaseFirestore.instance.collection('platos').doc(docId).update({
        'disponible': !actual,
      });
    } catch (e) {
      print("Error al actualizar disponibilidad: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Platos - ${widget.categoryName}'),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(hintText: 'Nombre del plato'),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(hintText: 'Descripción del plato'),
                ),
                TextField(
                  controller: _precioController,
                  decoration: InputDecoration(hintText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                IconButton(
                  icon: Icon(Icons.image, color: Colors.brown),
                  onPressed: _pickImage,
                ),
                SizedBox(height: 16),
                Text("Agregar Preguntas"),
                TextField(
                  controller: _preguntaController,
                  decoration: InputDecoration(hintText: 'Ingrese una pregunta'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _opcionController,
                        decoration: InputDecoration(hintText: 'Ingrese una opción'),
                      ),
                    ),
                    IconButton(
                      onPressed: _agregarOpcion,
                      icon: Icon(Icons.add, color: Colors.brown),
                    ),
                  ],
                ),
                ..._opciones.map((opcion) => ListTile(
                      title: Text(opcion),
                      trailing: Icon(Icons.delete, color: Colors.red),
                      onTap: () {
                        setState(() {
                          _opciones.remove(opcion);
                        });
                      },
                    )),
                ElevatedButton(
                  onPressed: _agregarPregunta,
                  child: Text("Agregar Pregunta"),
                ),
                ..._preguntas.map((pregunta) => ListTile(
                      title: Text(pregunta['pregunta']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: pregunta['opciones']
                            .map<Widget>((opcion) => Text("- $opcion"))
                            .toList(),
                      ),
                    )),
                ElevatedButton(
                  onPressed: _addPlato,
                  child: Text('Agregar Plato'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('platos')
                  .where('categoria', isEqualTo: widget.categoryName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return Center(child: Text("No hay platos disponibles."));

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final disponible = data['disponible'] ?? true;
                    return ListTile(
                      leading: Image.network(data['imagen'], height: 50, width: 50, fit: BoxFit.cover),
                      title: Text(data['nombre']),
                      subtitle: Text(data['descripcion']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(disponible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                            onPressed: () => _toggleDisponible(doc.id, disponible),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePlato(doc.id, data['imagen']),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
