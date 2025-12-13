import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 AGREGAR ESTA IMPORTACIÓN
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 AGREGAR ESTA IMPORTACIÓN

class CarritoAsignacionProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  // =============================
  // CONSTRUCTOR
  // =============================
  CarritoAsignacionProvider() {
    // 👈 AL INICIALIZAR EL PROVIDER, CARGA LOS DATOS DE FIRESTORE
    cargarItemsDeFirestore();
  }

  List<Map<String, dynamic>> get items => _items;

  // =============================
  // CARGAR ITEMS DESDE FIRESTORE
  // =============================
  Future<void> cargarItemsDeFirestore() async {
    // Obtener el ID del usuario actual (padre)
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Obtener todos los documentos de la subcolección 'items' del carrito
    final snapshot = await FirebaseFirestore.instance
        .collection("carritos")
        .doc(uid)
        .collection("items")
        .get();

    // Limpiar la lista actual y llenarla con los datos de Firestore
    _items.clear();
    _items.addAll(
        snapshot.docs.map((doc) => doc.data()).toList());

    // Notificar a los widgets (como EstudiantesRegistrados) que la lista ha cambiado
    notifyListeners();
  }

  // =============================
  // AGREGAR
  // =============================
  void agregar(Map<String, dynamic> data) {
    // Nota: El proceso de guardar en Firestore (que ocurre en PantallaMatriculaEstudiante)
    // es independiente, aquí solo se actualiza la lista local.
    _items.add(data);
    notifyListeners();
  }

  // =============================
  // ELIMINAR
  // =============================
  void eliminar(String estudianteId) {
    _items.removeWhere((item) => item["estudianteId"] == estudianteId);
    // Se recomienda también eliminar el documento de Firestore aquí si es necesario
    notifyListeners();
  }

  // =============================
  // VERIFICAR SI YA ESTÁ EN CARRITO
  // =============================
  bool contieneEstudiante(String estudianteId) {
    return _items.any((item) => item["estudianteId"] == estudianteId);
  }

  // =============================
  // VACIAR TRAS PAGO
  // =============================
  void limpiar() {
    _items.clear();
    // Se recomienda también eliminar la subcolección de Firestore aquí
    notifyListeners();
  }

  // =============================
  // TOTAL GLOBAL DEL CARRITO
  // =============================
  double get totalGlobal {
    double total = 0;
    for (var item in _items) {
      total += (item["montoFinal"] ?? 0.0);
    }
    return total;
  }
}