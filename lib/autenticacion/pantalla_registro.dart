// 📁 Ubicación: lib/autenticacion/pantalla_registro.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:club_huandoy/core/widgets/campo_texto_personalizado.dart';
import 'package:club_huandoy/core/widgets/boton_personalizado.dart';

// 👇 IMPORTA TU NUEVA PANTALLA
import 'verificar_correo.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confPassCtrl = TextEditingController();

  bool cargando = false;
  bool _verPass = false;
  bool _verConfPass = false;

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => cargando = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      // Crear usuario en colección 'usuarios'
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'correo': _emailCtrl.text.trim(),
        'rol': 'padre',
        'perfilCompleto': false,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      // Enviar verificación
      await cred.user!.sendEmailVerification();

      if (!mounted) return;

      // Redirigir a pantalla de verificación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PantallaVerificarCorreo(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error desconocido";

      if (e.code == 'email-already-in-use') {
        mensaje = "El correo ya está registrado.";
      } else if (e.code == 'invalid-email') {
        mensaje = "Correo inválido.";
      } else if (e.code == 'weak-password') {
        mensaje = "La contraseña es muy débil.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CampoTextoPersonalizado(
                  label: "Correo electrónico",
                  icono: Icons.email_outlined,
                  controlador: _emailCtrl,
                  tipo: TextInputType.emailAddress,
                  validador: (v) =>
                      v != null && v.contains("@") ? null : "Correo inválido",
                ),

                const SizedBox(height: 16),

                CampoTextoPersonalizado(
                  label: "Contraseña",
                  icono: Icons.lock_outline,
                  controlador: _passCtrl,
                  tipo: TextInputType.text,
                  esPassword: true,
                  mostrarPassword: _verPass,
                  onTogglePassword: () =>
                      setState(() => _verPass = !_verPass),
                  validador: (v) =>
                      v != null && v.length >= 6
                          ? null
                          : "Mínimo 6 caracteres",
                ),

                const SizedBox(height: 16),

                CampoTextoPersonalizado(
                  label: "Confirmar contraseña",
                  icono: Icons.lock_outline,
                  controlador: _confPassCtrl,
                  tipo: TextInputType.text,
                  esPassword: true,
                  mostrarPassword: _verConfPass,
                  onTogglePassword: () =>
                      setState(() => _verConfPass = !_verConfPass),
                  validador: (v) =>
                      v == _passCtrl.text ? null : "Las contraseñas no coinciden",
                ),

                const SizedBox(height: 24),

                BotonPersonalizado(
                  texto: "Registrarme",
                  cargando: cargando,
                  onPressed: _registrarUsuario,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
