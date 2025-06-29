import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔹 Agregado para usar Provider
import 'metodo_pago_screen.dart'; // Asegúrate de usar el path correcto
import '../provider/cart_provider.dart'; // 🔹 Importa tu CartProvider

class UbicacionScreen extends StatefulWidget {
  const UbicacionScreen({super.key});

  @override
  State<UbicacionScreen> createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController referenciaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xF2642424);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de Entrega'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.brown.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: TextField(
                controller: direccionController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.brown.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: TextField(
                controller: referenciaController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Referencia (opcional)',
                  prefixIcon: Icon(Icons.edit_location_alt),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                if (direccionController.text.trim().isEmpty) return;

                // 🔹 Guardamos la dirección y referencia en el CartProvider
                Provider.of<CartProvider>(context, listen: false)
                    .setDireccion(direccionController.text.trim());
                Provider.of<CartProvider>(context, listen: false)
                    .setReferencia(referenciaController.text.trim());

                // 🔹 Navegamos a la siguiente pantalla
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MetodoPagoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuar al Método de Pago'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFDF5F3),
    );
  }
}
