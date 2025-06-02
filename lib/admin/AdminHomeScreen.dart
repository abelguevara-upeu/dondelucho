import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/custom_bottom_nav_bar.dart';
import 'dart:io';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  File? _selectedImage;
  final picker = ImagePicker();
  List<String> promotionImages = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  void _loadPromotions() {
    FirebaseFirestore.instance.collection('promotions').snapshots().listen((snapshot) {
      setState(() {
        promotionImages = snapshot.docs
            .map((doc) => doc['image_url'] as String? ?? '')
            .where((url) => url.isNotEmpty)
            .toList();
      });
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('promotions/$fileName');

    try {
      await storageRef.putFile(_selectedImage!);
      String imageUrl = await storageRef.getDownloadURL();

      // Guardar URL en Firestore
      await FirebaseFirestore.instance.collection('promotions').add({'image_url': imageUrl});
      setState(() {
        _selectedImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imagen subida correctamente")));
    } catch (e) {
      print("Error al subir imagen: $e");
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Maneja la navegación según el índice
    switch (index) {
      case 0:
        // Ya estamos en AdminHomeScreen
        break;
      case 1:
        Navigator.pushNamed(context, '/categorias');
        break;
      case 2:
        Navigator.pushNamed(context, '/promociones');
        break;
      case 3:
        Navigator.pushNamed(context, '/pedidos');
        break;
      case 4:
        Navigator.pushNamed(context, '/cuenta');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo_principal.jpg',
          height: 80,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Selecciona una imagen de tu galería",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xF2642424)),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, color: Color(0xF2642424), size: 30),
                      onPressed: _pickImage,
                    ),
                    SizedBox(width: 20),
                    if (_selectedImage != null)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xF2642424)),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xF2642424),
                  ),
                  child: Text("Subir Imagen"),
                ),
              ],
            ),
          ),
          Expanded(
            child: promotionImages.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: promotionImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(promotionImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: 200,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
