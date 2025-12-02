//lib/core/providers/carrito_asignacion_provider.dart

import 'package:flutter/material.dart';

class CarritoAsignacionProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  // =============================
  // AGREGAR ASIGNACIÓN DE HORARIO
  // =============================
  void agregar(Map<String, dynamic> data) {
    _items.add(data);
    notifyListeners();
  }

  // =============================
  // ELIMINAR POR ID DEL ESTUDIANTE
  // =============================
  void eliminar(String estudianteId) {
    _items.removeWhere((item) => item["estudianteId"] == estudianteId);
    notifyListeners();
  }

  // =============================
  // VERIFICAR SI YA ESTÁ EN CARRITO
  // =============================
  bool contieneEstudiante(String estudianteId) {
    return _items.any((item) => item["estudianteId"] == estudianteId);
    notifyListeners();
    return false;
  }

  // =============================
  // VACIAR CARRITO TRAS PAGO
  // =============================
  void limpiar() {
    _items.clear();
    notifyListeners();
  }

  // =============================
  // SUMA LO QUE SE PAGARÁ
  // =============================
  double get totalGlobal {
    double total = 0;
    for (var item in _items) {
      total += (item["montoFinal"] ?? 0);
    }
    return total;
  }
}
