import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'platos_categoria_screen.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Categorías',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar categorías',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!.docs;

                final filteredCategories = categories.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toLowerCase() ?? '';
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredCategories.isEmpty) {
                  return const Center(child: Text('No hay categorías disponibles.'));
                }

                return ListView.builder(
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final data = filteredCategories[index].data() as Map<String, dynamic>;
                    final categoryName = data['name'] ?? '';
                    final imageUrl = data['image_url'] ?? '';

                    return _categoryItem(context, imageUrl, categoryName);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryItem(BuildContext context, String imagePath, String title) {
    return GestureDetector(
      onTap: () {
        print("🟢 Enviando categoría: $title");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlatosCategoriaScreen(
              categoria: title,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Image.network(imagePath, height: 60, width: 60, fit: BoxFit.cover),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
