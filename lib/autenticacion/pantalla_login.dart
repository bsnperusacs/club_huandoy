import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:club_huandoy/core/widgets/campo_texto_personalizado.dart';
import 'package:club_huandoy/core/servicios/servicio_autenticacion.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final ServicioAutenticacion _authServicio = ServicioAutenticacion();

  bool cargando = false;
  bool verPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Image.asset(
              'assets/imagenes/Logo_huandoy.png',
              width: 120,
            ),

            const SizedBox(height: 20),
            const Text(
              "Bienvenido",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  CampoTextoPersonalizado(
                    label: "Correo electrónico",
                    icono: Icons.email_outlined,
                    controlador: _emailCtrl,
                    tipo: TextInputType.emailAddress,
                    validador: (v) =>
                        v == null || v.isEmpty ? "Ingresa tu correo" : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !verPassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          verPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => verPassword = !verPassword);
                        },
                      ),
                    ),
                    validator: (v) =>
                        v != null && v.length >= 6
                            ? null
                            : "Mínimo 6 caracteres",
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _recuperarPassword,
                      child: const Text("¿Olvidaste tu contraseña?"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: cargando
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _iniciarSesion();
                              }
                            },
                      child: cargando
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )
                          : const Text(
                              "Iniciar sesión",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes cuenta?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/registro');
                        },
                        child: const Text(
                          "Regístrate",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 40),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                    label: const Text("Iniciar con Google"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _iniciarConGoogle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔐 LOGIN CORREO (CON VERIFICACIÓN DE EMAIL)
  Future<void> _iniciarSesion() async {
    setState(() => cargando = true);

    try {
      await _authServicio.iniciarConCorreo(
        correo: _emailCtrl.text.trim(),
        contrasena: _passCtrl.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tu correo no está verificado. Revisa tu email.',
            ),
          ),
        );
        return;
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // 🔐 GOOGLE
  Future<void> _iniciarConGoogle() async {
    await _authServicio.iniciarConGoogle();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  // 🔐 RECUPERAR PASSWORD
  Future<void> _recuperarPassword() async {
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa tu correo primero")),
      );
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _emailCtrl.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Correo de recuperación enviado")),
    );
  }
}
