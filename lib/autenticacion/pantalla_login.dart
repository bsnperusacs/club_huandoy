import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Widgets
import 'package:club_huandoy/core/widgets/campo_texto_personalizado.dart';

// Servicio
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
              height: 120,
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

                  CampoTextoPersonalizado(
                    label: "Contraseña",
                    icono: Icons.lock_outline,
                    controlador: _passCtrl,
                    tipo: TextInputType.text,
                    esPassword: true,
                    validador: (v) =>
                        v != null && v.length >= 6
                            ? null
                            : "Mínimo 6 caracteres",
                  ),

                  const SizedBox(height: 24),

SizedBox(
  width: 200,
  height: 60,
  child: ElevatedButton(
    onPressed: cargando
        ? null
        : () {
            if (_formKey.currentState!.validate()) {
              _iniciarSesion();
            }
          },
    child: cargando
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Text("Iniciar Sesión"),
  ),
),


                  const SizedBox(height: 20),

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

  // 🔐 LOGIN CORREO
  Future<void> _iniciarSesion() async {
    setState(() => cargando = true);
    try {
      await _authServicio.iniciarConCorreo(
        correo: _emailCtrl.text.trim(),
        contrasena: _passCtrl.text.trim(),
      );

      if (!mounted) return;

      // 🔥 LIMPIA TODA LA PILA
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // 🔐 LOGIN GOOGLE
  Future<void> _iniciarConGoogle() async {
    await _authServicio.iniciarConGoogle();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }
}
