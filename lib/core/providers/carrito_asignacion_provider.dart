// lib/core/providers/carrito_asignacion_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarritoAsignacionProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  StreamSubscription<QuerySnapshot>? _sub;

  // =============================
  // CONSTRUCTOR
  // =============================
  CarritoAsignacionProvider() {
    _escucharCarritoFirestore();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // =============================
  // GETTERS
  // =============================
  List<Map<String, dynamic>> get items => _items;

  // =============================
  // ESCUCHAR FIRESTORE (TIEMPO REAL)
  // =============================
  void _escucharCarritoFirestore() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _sub = FirebaseFirestore.instance
        .collection("carritos")
        .doc(uid)
        .collection("items")
        .snapshots()
        .listen((snapshot) {
      _items
        ..clear()
        ..addAll(snapshot.docs.map((d) => d.data()));
      notifyListeners();
    });
  }

  // =============================
  // AGREGAR ITEM (USADO EN MATRÍCULA / ASIGNAR HORARIO)
  // =============================
  void agregar(Map<String, dynamic> data) {
    _items.add(data);
    notifyListeners();
  }

  // =============================
  // ELIMINAR POR ESTUDIANTE
  // =============================
  void eliminar(String estudianteId) {
    _items.removeWhere((item) => item["estudianteId"] == estudianteId);
    notifyListeners();
  }

  // =============================
  // VERIFICAR SI YA EXISTE ESTUDIANTE
  // =============================
  bool contieneEstudiante(String estudianteId) {
    return _items.any((item) => item["estudianteId"] == estudianteId);
  }

  // =============================
  // LIMPIAR TRAS PAGO EXITOSO
  // =============================
  void limpiar() {
    _items.clear();
    notifyListeners();
  }

  // =============================
  // TOTAL GLOBAL
  // =============================
  double get totalGlobal {
    double total = 0;
    for (final item in _items) {
      total += (item["montoFinal"] ?? 0).toDouble();
    }
    return total;
  }
}
