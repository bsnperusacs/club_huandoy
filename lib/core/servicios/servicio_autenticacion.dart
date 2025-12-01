// 📁 Ubicación: lib/core/servicios/servicio_autenticacion.dart.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class ServicioAutenticacion {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Usuario actual
  User? get usuarioActual => _auth.currentUser;

  // Cambios de auth
  Stream<User?> get cambiosUsuario => _auth.authStateChanges();

  // ============================================================
  // LOGIN CON CORREO
  // ============================================================
  Future<UserCredential> iniciarConCorreo({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena.trim(),
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw 'Correo no registrado';
      if (e.code == 'wrong-password') throw 'Contraseña incorrecta';
      throw 'Error al iniciar sesión';
    }
  }

  // ============================================================
  // REGISTRO CON CORREO
  // ============================================================
  Future<UserCredential> registrarConCorreo({
    required String correo,
    required String contrasena,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: correo.trim(),
      password: contrasena.trim(),
    );

    // Enviar email de verificación
    await cred.user!.sendEmailVerification();

    return cred;
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // ============================================================
  // RECUPERAR CONTRASEÑA
  // ============================================================
  Future<void> enviarCorreoRecuperacion(String correo) async {
    await _auth.sendPasswordResetEmail(email: correo.trim());
  }

  // ============================================================
  // CONSULTAR SI EL CORREO ESTÁ VERIFICADO
  // ============================================================
  Future<bool> estaVerificado() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    return _auth.currentUser!.emailVerified;
  }

  // ============================================================
  // REENVIAR EMAIL DE VERIFICACIÓN
  // ============================================================
  Future<void> reenviarCorreoVerificacion() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ============================================================
  // LOGIN CON GOOGLE
  // ============================================================
  Future<UserCredential?> iniciarConGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider provider = GoogleAuthProvider();
        provider.addScope('email');
        return await _auth.signInWithPopup(provider);
      }

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("❌ Error Google Login: $e");
      return null;
    }
  }
}
