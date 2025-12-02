import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_huandoy/core/modelos/estudiante_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EstudianteController {
  final picker = ImagePicker();
  File? imagenSeleccionada;

  // ==========================================================
  // SELECCIONAR IMAGEN
  // ==========================================================
  Future<void> seleccionarImagen() async {
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (file != null) {
      imagenSeleccionada = File(file.path);
    }
  }

  // ==========================================================
  // SUBIR FOTO A FIREBASE STORAGE
  // ==========================================================
  Future<String> subirFoto(String estudianteId) async {
    if (imagenSeleccionada == null) return "";

    final padreId = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child("estudiantes/$padreId/$estudianteId/foto.jpg");

    await ref.putFile(imagenSeleccionada!);

    return await ref.getDownloadURL();
  }

  // ==========================================================
  // GUARDAR ESTUDIANTE EN FIRESTORE
  // ==========================================================
  Future<void> registrarEstudiante(Estudiante estudiante) async {
    await FirebaseFirestore.instance
        .collection("estudiantes")
        .doc(estudiante.id)
        .set(estudiante.toMap());
  }
}
