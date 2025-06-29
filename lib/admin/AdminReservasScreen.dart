import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReservasScreen extends StatefulWidget {
  const AdminReservasScreen({super.key});

  @override
  State<AdminReservasScreen> createState() => _AdminReservasScreenState();
}

class _AdminReservasScreenState extends State<AdminReservasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas Pendientes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reserva')
            .orderBy('fecha', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay reservas registradas.'));
          }

          final reservas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final reserva = reservas[index];
              final nombre = reserva['nombre'] ?? 'Desconocido';
              final apellido = reserva['apellido'] ?? 'Desconocido';
              final fecha = (reserva['fecha'] as Timestamp).toDate();
              final hora = reserva['hora'];
              final cantidad = reserva['cantidad_personas'];
              final estado = reserva['estado'];

              Color estadoColor = Colors.grey;
              if (estado == 'aceptado') estadoColor = Colors.green;
              if (estado == 'denegado') estadoColor = Colors.red;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('$nombre $apellido'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: ${fecha.toLocal().toString().split(' ')[0]}'),
                      Text('Hora: $hora'),
                      Text('Personas: $cantidad'),
                      Text('Estado: $estado', style: TextStyle(color: estadoColor)),
                    ],
                  ),
                  trailing: estado == 'pendiente'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => actualizarEstado(reserva.id, 'aceptado'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => actualizarEstado(reserva.id, 'denegado'),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> actualizarEstado(String idReserva, String nuevoEstado) async {
    await FirebaseFirestore.instance
        .collection('reserva')
        .doc(idReserva)
        .update({'estado': nuevoEstado});
  }
}
