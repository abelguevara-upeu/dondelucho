import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class MisReservasScreen extends StatefulWidget {
  @override
  _MisReservasScreenState createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;
  List<DocumentSnapshot> _reservas = [];

  TimeOfDay? _horaSeleccionada;
  int _cantidad = 1;

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDate;
    cargarReservas();
  }

  Future<void> cargarReservas() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('reserva')
          .where('id_usuario', isEqualTo: user.uid)
          .get();
      setState(() {
        _reservas = snapshot.docs;
      });
    }
  }

  Future<void> crearReserva() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _selectedDate != null && _horaSeleccionada != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      final nombre = userData.data()?['nombre'] ?? 'SinNombre';
      final apellido = userData.data()?['apellido'] ?? 'SinApellido';

      final horaTexto = _horaSeleccionada!.format(context);

      await FirebaseFirestore.instance.collection('reserva').add({
        'id_usuario': user.uid,
        'nombre': nombre,
        'apellido': apellido,
        'fecha': _selectedDate,
        'hora': horaTexto,
        'cantidad_personas': _cantidad,
        'estado': 'pendiente',
      });

      setState(() {
        _horaSeleccionada = null;
        _cantidad = 1;
      });

      cargarReservas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservasFechaSeleccionada = _reservas.where((r) {
      final fecha = (r['fecha'] as Timestamp).toDate();
      return fecha.year == _selectedDate!.year &&
          fecha.month == _selectedDate!.month &&
          fecha.day == _selectedDate!.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Mis Reservas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDate,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) =>
                  isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDate = focusedDay;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _horaSeleccionada = picked;
                        });
                      }
                    },
                    child: Text(
                      _horaSeleccionada == null
                          ? 'Seleccionar hora'
                          : 'Hora: ${_horaSeleccionada!.format(context)}',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: _cantidad,
                  items: List.generate(10, (index) => index + 1)
                      .map((e) => DropdownMenuItem(
                            child: Text('$e personas'),
                            value: e,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _cantidad = value ?? 1;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: (_horaSeleccionada != null) ? crearReserva : null,
              child: Text('Crear reserva para esta fecha'),
            ),
            Divider(height: 30),
            Expanded(
              child: reservasFechaSeleccionada.isEmpty
                  ? Center(child: Text('No hay reservas para esta fecha'))
                  : ListView.builder(
                      itemCount: reservasFechaSeleccionada.length,
                      itemBuilder: (context, index) {
                        final r = reservasFechaSeleccionada[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              'Reserva: ${r['fecha'].toDate().toLocal().toString().split(" ")[0]}',
                            ),
                            subtitle: Text(
                              'Hora: ${r['hora']} | Personas: ${r['cantidad_personas']} | Estado: ${r['estado']}',
                            ),
                          ),
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
