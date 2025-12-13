import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaRecuperar extends StatefulWidget {
  const PantallaRecuperar({super.key});

  @override
  State<PantallaRecuperar> createState() => _PantallaRecuperarState();
}

class _PantallaRecuperarState extends State<PantallaRecuperar> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  bool cargando = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar contraseña"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 25),

                  // =============================
                  // INPUT — USANDO THEME GLOBAL
                  // =============================
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Ingrese su correo";
                      }
                      if (!v.contains("@")) return "Correo no válido";
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // =============================
                  // BOTÓN — USANDO ELEVATEDBUTTON THEME
                  // =============================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: cargando ? null : _recuperar,
                      child: cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Enviar enlace",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Volver al inicio de sesión",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====================================
  // 🔥 FUNCIÓN PARA ENVIAR EL CORREO
  // ====================================
  Future<void> _recuperar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => cargando = true);

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _correoCtrl.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Te enviamos un enlace a tu correo."),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }
}
