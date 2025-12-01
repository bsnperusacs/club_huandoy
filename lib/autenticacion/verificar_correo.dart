// 📌 Ubicación: lib/autenticacion/verificar_correo.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaVerificarCorreo extends StatefulWidget {
  const PantallaVerificarCorreo({super.key});

  @override
  State<PantallaVerificarCorreo> createState() =>
      _PantallaVerificarCorreoState();
}

class _PantallaVerificarCorreoState extends State<PantallaVerificarCorreo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool enviando = false;
  bool verificado = false;

  @override
  void initState() {
    super.initState();
    usuario = _auth.currentUser;
    verificarEstado();
  }

  Future<void> verificarEstado() async {
    await usuario?.reload();
    usuario = _auth.currentUser;

    setState(() {
      verificado = usuario?.emailVerified ?? false;
    });

    if (verificado && mounted) {
      Navigator.pushReplacementNamed(context, '/inicio');
    }
  }

  Future<void> reenviarCorreo() async {
    if (usuario == null) return;

    setState(() => enviando = true);

    try {
      await usuario!.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📨 Correo de verificación enviado. Revisa tu bandeja de entrada.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verificar correo")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read, size: 100, color: Colors.blue),
            const SizedBox(height: 20),

            const Text(
              "Revisa tu bandeja de entrada",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const Text(
              "Te enviamos un correo de verificación.\n\n"
              "Si no aparece en unos segundos, revisa también:\n"
              "• 📨 Correo no deseado\n"
              "• 🚫 Carpeta Spam\n"
              "• 📥 Promociones (en Gmail)\n\n"
              "Una vez verificado podrás continuar.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Ya verifiqué mi correo"),
              onPressed: verificarEstado,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: enviando ? null : reenviarCorreo,
              child: enviando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Reenviar correo"),
            ),
          ],
        ),
      ),
    );
  }
}
