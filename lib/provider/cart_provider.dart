import 'package:flutter/material.dart';

class CartItem {
  final String idPlato;
  final String nombre;
  final String descripcion;
  final String imagen;
  final double precio;
  int cantidad;

  CartItem({
    required this.idPlato,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.precio,
    this.cantidad = 1,
  });

  double get subtotal => cantidad * precio;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  // 🔽 NUEVOS CAMPOS PARA DIRECCIÓN Y REFERENCIA
  String _direccion = '';
  String _referencia = '';

  List<CartItem> get items => _items;

  // 🔽 NUEVOS GETTERS
  String get direccion => _direccion;
  String get referencia => _referencia;

  // 🔽 NUEVOS SETTERS
  void setDireccion(String direccion) {
    _direccion = direccion;
    notifyListeners();
  }

  void setReferencia(String referencia) {
    _referencia = referencia;
    notifyListeners();
  }

  void addItem(CartItem item) {
    final index = _items.indexWhere((element) => element.idPlato == item.idPlato);
    if (index >= 0) {
      _items[index].cantidad += item.cantidad;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String idPlato) {
    _items.removeWhere((item) => item.idPlato == idPlato);
    notifyListeners();
  }

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
