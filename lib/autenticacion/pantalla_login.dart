import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTS CORRECTOS SEGÚN TU PROYECTO
import 'package:club_huandoy/core/widgets/campo_texto_personalizado.dart';
import 'package:club_huandoy/core/widgets/boton_personalizado.dart';

// SERVICIO REAL SEGÚN TU ESTRUCTURA
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

  Future<String?> _leerRol(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    return snap.data()?['rol'] ?? 'padre';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  // EMAIL
                  CampoTextoPersonalizado(
                    label: "Correo electrónico",
                    icono: Icons.email_outlined,
                    controlador: _emailCtrl,
                    tipo: TextInputType.emailAddress,
                    validador: (v) =>
                        v == null || v.isEmpty ? "Ingresa tu correo" : null,
                  ),

                  const SizedBox(height: 16),

                  // CONTRASEÑA
                  CampoTextoPersonalizado(
                    label: "Contraseña",
                    icono: Icons.lock_outline,
                    controlador: _passCtrl,
                    tipo: TextInputType.text, // ← NECESARIO
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
                    child: BotonPersonalizado(
                      texto: "Iniciar Sesión",
                      cargando: cargando,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _iniciarSesion();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/recuperar'),
                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                    label: const Text("Iniciar con Google"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _iniciarConGoogle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/registro'),
              child: const Text(
                "¿No tienes cuenta? Regístrate aquí",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // LOGIN NORMAL
  // ===============================
  Future<void> _iniciarSesion() async {
    setState(() => cargando = true);

    try {
      final cred = await _authServicio.iniciarConCorreo(
        correo: _emailCtrl.text.trim(),
        contrasena: _passCtrl.text.trim(),
      );

      await _procesarIngreso(cred.user);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // ===============================
  // LOGIN GOOGLE
  // ===============================
  Future<void> _iniciarConGoogle() async {
    final userCred = await _authServicio.iniciarConGoogle();
    await _procesarIngreso(userCred?.user);
  }

  // ===============================
  // PROCESAR ROL
  // ===============================
  Future<void> _procesarIngreso(User? user) async {
    if (user == null || !mounted) return;

    final rol = await _leerRol(user.uid);

    if (rol == "admin") {
      Navigator.pushReplacementNamed(context, '/adminHome');
      return;
    }

    await _verificarPerfilPadre(user);
  }

  // ===============================
  // VERIFICAR REGISTRO PADRE
  // ===============================
  Future<void> _verificarPerfilPadre(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('padres')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (!doc.exists || (doc.data()?['registroCompleto'] != true)) {
      Navigator.pushReplacementNamed(context, '/registroPadre');
    } else {
      Navigator.pushReplacementNamed(context, '/inicio');
    }
  }
}
