// 📁 Ubicación: lib/autenticacion/pantalla_registro.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:club_huandoy/core/widgets/campo_texto_personalizado.dart';
import 'verificar_correo.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();

  final _dniCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confPassCtrl = TextEditingController();

  String rolSeleccionado = 'padre';
  bool cargando = false;
  bool _verPass = false;
  bool _verConfPass = false;

  bool dniValidado = false;
  bool validandoDni = false;

  final Map<String, bool> especialidades = {
    'Preparación física': false,
    'Técnica individual': false,
    'Táctica': false,
    'Porteros': false,
    'Formativas': false,
    'Alto rendimiento': false,
  };

  final Map<String, bool> categorias = {
    'Sub 6': false,
    'Sub 8': false,
    'Sub 10': false,
    'Sub 12': false,
    'Sub 14': false,
    'Juvenil': false,
    'Libre': false,
  };

  final Map<String, bool> tipoEnsenanza = {
    'Formativa': false,
    'Competitiva': false,
    'Recreativa': false,
    'Alto rendimiento': false,
  };

  bool get esEntrenador => rolSeleccionado == 'entrenador';

  Future<void> _validarDniEntrenador() async {
    final dni = _dniCtrl.text.trim();
    if (dni.length != 8) {
      _alerta('DNI inválido');
      return;
    }

    setState(() => validandoDni = true);

    final snap = await FirebaseFirestore.instance
        .collection('entrenadores')
        .doc(dni)
        .get();

    setState(() => validandoDni = false);

    if (!snap.exists) {
      dniValidado = false;
      _alerta(
        'Usted aún no forma parte del equipo técnico del Club Deportivo Integral Huandoy SACs',
      );
      return;
    }

    setState(() => dniValidado = true);
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    if (esEntrenador && !dniValidado) {
      _alerta('Debe validar el DNI del entrenador');
      return;
    }

    setState(() => cargando = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'correo': _emailCtrl.text.trim(),
        'rol': rolSeleccionado,
        'dni': esEntrenador ? _dniCtrl.text.trim() : null,
        'especialidades': especialidades.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        'categorias': categorias.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        'tipoEnsenanza': tipoEnsenanza.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        'perfilCompleto': false,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      await cred.user!.sendEmailVerification();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaVerificarCorreo()),
      );
    } on FirebaseAuthException catch (e) {
      String m = 'Error desconocido';
      if (e.code == 'email-already-in-use') m = 'Correo ya registrado';
      if (e.code == 'invalid-email') m = 'Correo inválido';
      if (e.code == 'weak-password') m = 'Contraseña débil';
      _alerta(m);
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _alerta(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildChecks(String titulo, Map<String, bool> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...data.keys.map(
          (k) => CheckboxListTile(
            value: data[k],
            title: Text(k),
            onChanged: (v) => setState(() => data[k] = v ?? false),
          ),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: rolSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de usuario',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'padre', child: Text('Padre / Tutor')),
                    DropdownMenuItem(value: 'entrenador', child: Text('Entrenador')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      rolSeleccionado = v!;
                      dniValidado = false;
                    });
                  },
                ),

                const SizedBox(height: 16),

                if (esEntrenador) ...[
                  CampoTextoPersonalizado(
                    label: 'DNI',
                    icono: Icons.badge,
                    controlador: _dniCtrl,
                    tipo: TextInputType.number,
                    validador: (v) =>
                        v != null && v.length == 8 ? null : 'DNI inválido',
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: validandoDni ? null : _validarDniEntrenador,
                    child: validandoDni
                        ? const CircularProgressIndicator()
                        : const Text('Validar DNI'),
                  ),
                  const SizedBox(height: 16),

                  if (dniValidado) ...[
                    _buildChecks('Especialidades', especialidades),
                    _buildChecks('Categorías', categorias),
                    _buildChecks('Tipo de enseñanza', tipoEnsenanza),
                  ],
                ],

                if (!esEntrenador || dniValidado) ...[
                  CampoTextoPersonalizado(
                    label: 'Correo',
                    icono: Icons.email,
                    controlador: _emailCtrl,
                    tipo: TextInputType.emailAddress,
                    validador: (v) =>
                        v != null && v.contains('@') ? null : 'Correo inválido',
                  ),
                  const SizedBox(height: 16),
                  CampoTextoPersonalizado(
                    label: 'Contraseña',
                    icono: Icons.lock,
                    controlador: _passCtrl,
                    tipo: TextInputType.text,
                    esPassword: true,
                    mostrarPassword: _verPass,
                    onTogglePassword: () =>
                        setState(() => _verPass = !_verPass),
                    validador: (v) =>
                        v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
                  ),
                  const SizedBox(height: 16),
                  CampoTextoPersonalizado(
                    label: 'Confirmar contraseña',
                    icono: Icons.lock,
                    controlador: _confPassCtrl,
                    tipo: TextInputType.text,
                    esPassword: true,
                    mostrarPassword: _verConfPass,
                    onTogglePassword: () =>
                        setState(() => _verConfPass = !_verConfPass),
                    validador: (v) =>
                        v == _passCtrl.text ? null : 'No coinciden',
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: cargando ? null : _registrarUsuario,
                    child: cargando
                        ? const CircularProgressIndicator()
                        : const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
