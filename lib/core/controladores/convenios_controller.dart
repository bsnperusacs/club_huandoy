//📁 lib/core/controladores/convenios_controller.dart 

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/convenio_model.dart';

class ConveniosController {
  final _db = FirebaseFirestore.instance;

  // LISTAR
  Stream<QuerySnapshot> listarConvenios() {
    return _db.collection('convenios').orderBy('titulo').snapshots();
  }

  // CREAR
  Future<String> crearConvenio(Map<String, dynamic> data) async {
    final doc = await _db.collection('convenios').add(data);
    return doc.id;
  }

  // EDITAR
  Future<void> editarConvenio(String id, Map<String, dynamic> data) async {
    await _db.collection('convenios').doc(id).update(data);
  }

  // ACTIVAR / DESACTIVAR
  Future<void> activar(String id) async =>
      _db.collection('convenios').doc(id).update({'activo': true});

  Future<void> desactivar(String id) async =>
      _db.collection('convenios').doc(id).update({'activo': false});

  // ===========================================================
  // VALIDAR CÓDIGO
  // ===========================================================
  Future<ConvenioModel?> obtenerConvenio(String codigo) async {
    final query = await _db
        .collection('convenios')
        .where('codigo', isEqualTo: codigo)
        .where('activo', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return ConvenioModel.fromFirestore(query.docs.first);
  }

  // ===========================================================
  // VALIDAR ORDEN DE CÓDIGOS
  // ===========================================================
  Future<Map<String, dynamic>> validarOrden(
      String codigo1, String codigo2) async {
    final c1 = await obtenerConvenio(codigo1);
    final c2 = await obtenerConvenio(codigo2);

    if (c1 == null || c2 == null) {
      return {
        'ok': false,
        'mensaje': "Uno de los códigos no existe o está inactivo.",
      };
    }

    final ambosNoAcumulables =
        !c1.acumulableConOtros && !c2.acumulableConOtros;

    if (ambosNoAcumulables) {
      return {
        'ok': false,
        'mensaje': "Estos códigos no pueden combinarse.",
      };
    }

    // Caso permitido: código acumulable debe IR PRIMERO
    if (c1.acumulableConOtros && !c2.acumulableConOtros) {
      return {'ok': true};
    }

    // Caso invertido
    if (!c1.acumulableConOtros && c2.acumulableConOtros) {
      return {
        'ok': false,
        'mensaje':
            "El código ${c2.codigo} permite combinarse, pero debe ingresarse primero.",
        'ordenCorrecto': [c2.codigo, c1.codigo],
      };
    }

    // Ambos acumulables → NO PERMITIDO
    if (c1.acumulableConOtros && c2.acumulableConOtros) {
      return {
        'ok': false,
        'mensaje':
            "No se pueden combinar dos códigos que permiten acumulación.",
      };
    }

    return {'ok': false, 'mensaje': "Combinación no válida."};
  }
}
