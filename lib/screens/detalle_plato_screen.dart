import 'package:flutter/material.dart';

class DetallePlatoScreen extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final List<Map<String, dynamic>> preguntas; // Cambiado a List<Map<String, dynamic>>

  DetallePlatoScreen({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.preguntas,
    required List opciones,
  });

  @override
  _DetallePlatoScreenState createState() => _DetallePlatoScreenState();
}

class _DetallePlatoScreenState extends State<DetallePlatoScreen> {
  Map<String, String> selectedOptions = {}; // Para almacenar las opciones seleccionadas por pregunta

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del plato
            Image.network(widget.imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 5),
                  Text("4.7 (200 calificaciones)", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.description,
                style: TextStyle(fontSize: 16),
              ),
            ),
            // Preguntas dinámicas con sus opciones
            if (widget.preguntas.isNotEmpty)
              ...widget.preguntas.map((pregunta) {
                String preguntaTexto = pregunta['pregunta'] ?? 'Pregunta no disponible';
                List<String> opciones = List<String>.from(pregunta['opciones'] ?? []);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preguntaTexto,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: opciones.map((opcion) {
                          return RadioListTile(
                            title: Text(opcion),
                            value: opcion,
                            groupValue: selectedOptions[preguntaTexto], // Valor seleccionado para esta pregunta
                            onChanged: (value) {
                              setState(() {
                                selectedOptions[preguntaTexto] = value.toString();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            // Botón "Añadir al carrito"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Validar que todas las preguntas tengan una respuesta
                  if (selectedOptions.length != widget.preguntas.length) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Por favor selecciona todas las opciones antes de añadir al carrito."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // Lógica para añadir al carrito
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Añadido al carrito correctamente."),
                        backgroundColor: const Color.fromARGB(255, 0, 121, 0),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  "(1) Añadir al carrito: s/${widget.price}",
                  style: TextStyle(
                    color: Colors.white, // Cambiado el color de la letra a blanco
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xF2642424),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
