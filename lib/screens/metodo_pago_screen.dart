import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provider/cart_provider.dart';

class MetodoPagoScreen extends StatelessWidget {
  const MetodoPagoScreen({super.key});

  Future<void> createPreferenceAndRedirect(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final direccion = cartProvider.direccion;
    final referencia = cartProvider.referencia;
    final total = cartProvider.total;

    // Convertir lista de CartItem a formato requerido por Mercado Pago
    final List<Map<String, dynamic>> items = cartProvider.items.map((item) {
      return {
        "id": item.idPlato,
        "title": item.nombre,
        "description": item.descripcion,
        "pictureUrl": item.imagen,
        "categoryId": "comida", // puedes usar algo más dinámico si lo deseas
        "quantity": item.cantidad,
        "price": item.precio,
      };
    }).toList();

    final Map<String, dynamic> requestData = {
      "orderId": "ORD-${DateTime.now().millisecondsSinceEpoch}",
      "direccion": direccion,
      "referencia": referencia,
      "total": total,
      "items": items,
    };

    const String apiUrl = "https://dondelucho.koyeb.app/api/payment/create-preference";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("RESPONSE DATA ===> $responseData");
        final String initPoint = responseData['sandboxInitPoint'];

        if (await canLaunchUrl(Uri.parse(initPoint))) {
          await launchUrl(Uri.parse(initPoint), mode: LaunchMode.externalApplication);
        } else {
          throw Exception('No se pudo abrir el enlace de pago.');
        }
      } else {
        print("Error al crear preferencia: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final carrito = cartProvider.items;
    final total = cartProvider.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
        backgroundColor: const Color(0xF2642424),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Resumen del Pedido',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                final item = carrito[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.imagen, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(item.nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.descripcion),
                        Text('Cantidad: ${item.cantidad}'),
                      ],
                    ),
                    trailing: Text('S/ ${item.precio.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total a pagar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('S/ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () => createPreferenceAndRedirect(context),
              icon: const Icon(Icons.payment),
              label: const Text('Pagar con Mercado Pago'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xF2642424),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      backgroundColor: const Color(0xFFFDF5F3),
    );
  }
}
