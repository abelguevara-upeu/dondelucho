import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'AdminPlatosScreen.dart';

class AdminCategoryScreen extends StatefulWidget {
  @override
  _AdminCategoryScreenState createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();
  File? _selectedImage;
  final picker = ImagePicker();

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

  Future<void> _addCategory() async {
    if (_categoryController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debe ingresar un nombre y seleccionar una imagen.")),
      );
      return;
    }

    String categoryName = _categoryController.text.trim();
    String fileName = "main_image_${DateTime.now().millisecondsSinceEpoch}";
    final storageRef = FirebaseStorage.instance.ref().child('categories/$categoryName/$fileName');

    try {
      await storageRef.putFile(_selectedImage!);
      String imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('categories').doc(categoryName.toLowerCase()).set({
        'name': categoryName,
        'image_url': imageUrl,
      });

      setState(() {
        _categoryController.clear();
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Categoría agregada correctamente.")),
      );
    } catch (e, stack) {
      print(" Error al agregar categoría: $e");
      print(" Stacktrace: $stack");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Error al agregar categoría: ${e.toString()}")),
  );
}
  }

  Future<void> _deleteCategory(String categoryName, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(categoryName.toLowerCase()).delete();

      final categoryFolder = FirebaseStorage.instance.ref().child('categories/$categoryName');
      await categoryFolder.listAll().then((result) async {
        for (var file in result.items) {
          await file.delete();
        }
        await categoryFolder.delete();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Categoría eliminada correctamente.")),
      );
    } catch (e) {
      print("Error al eliminar categoría: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar categoría.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categorías - Admin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      hintText: 'Ingrese categoría',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: _addCategory,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Previsualización de imagen seleccionada
            if (_selectedImage != null)
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No hay categorías disponibles."));
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(data['image_url'], height: 80, width: 80, fit: BoxFit.cover),
                        ),
                        title: Text(
                          data['name'],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(data['name'], data['image_url']),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdminPlatosScreen(categoryName: data['name']),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
