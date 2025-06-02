import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalle_plato_screen.dart';

class PlatosCategoriaScreen extends StatefulWidget {
  final String categoria;

  PlatosCategoriaScreen({required this.categoria});

  @override
  _PlatosCategoriaScreenState createState() => _PlatosCategoriaScreenState();
}

class _PlatosCategoriaScreenState extends State<PlatosCategoriaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Platos ${widget.categoria}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar platos",
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 16),
            // Lista de platos desde Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .doc(widget.categoria.toLowerCase())
                    .collection('platos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No hay platos disponibles.'));
                  }

                  final filteredPlatos = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = data['nombre']?.toLowerCase() ?? '';
                    return nombre.contains(_searchQuery);
                  }).toList();

                  if (filteredPlatos.isEmpty) {
                    return Center(child: Text('No se encontraron platos.'));
                  }

                  return ListView.builder(
                    itemCount: filteredPlatos.length,
                    itemBuilder: (context, index) {
                      final data = filteredPlatos[index].data() as Map<String, dynamic>;
                      return _buildDishItem(
                        context,
                        data['nombre'] ?? 'Nombre no disponible',
                        data['descripcion'] ?? 'Descripción no disponible',
                        data['imagen'] ?? '',
                        (data['precio'] ?? 0).toDouble(),
                        List<Map<String, dynamic>>.from(data['preguntas'] ?? []),
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

  Widget _buildDishItem(
    BuildContext context,
    String title,
    String description,
    String imageUrl,
    double price,
    List<Map<String, dynamic>> preguntas,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallePlatoScreen(
              title: title,
              description: description,
              imageUrl: imageUrl,
              price: price,
              preguntas: preguntas,
              opciones: [],
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('s/ $price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
