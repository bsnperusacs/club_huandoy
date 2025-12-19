import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:club_huandoy/core/theme/app_theme.dart';
import 'package:club_huandoy/core/theme/colores.dart';

class PantallaLibroReclamaciones extends StatefulWidget {
  const PantallaLibroReclamaciones({super.key});

  @override
  State<PantallaLibroReclamaciones> createState() =>
      _PantallaLibroReclamacionesState();
}

class _PantallaLibroReclamacionesState
    extends State<PantallaLibroReclamaciones> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _detalleCtrl = TextEditingController();
  final _pedidoCtrl = TextEditingController();

  bool _acepto = false;
  bool _enviando = false;

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate() || !_acepto) return;

    setState(() => _enviando = true);

    final id = const Uuid().v4();

    await FirebaseFirestore.instance
        .collection('libro_reclamaciones')
        .doc(id)
        .set({
      'id': id,
      'uid': FirebaseAuth.instance.currentUser?.uid,
      'nombre': _nombreCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'celular': _celularCtrl.text.trim(),
      'detalle': _detalleCtrl.text.trim(),
      'pedido': _pedidoCtrl.text.trim(),
      'estado': 'Pendiente',
      'fecha': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    setState(() => _enviando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reclamación enviada correctamente")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Libro de Reclamaciones"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.headerGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Libro de Reclamaciones Virtual",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Registra reclamos o quejas relacionadas con los "
                      "servicios del Club Deportivo Integral Huandoy. "
                      "La información será tratada de forma confidencial.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== FORM =====
              _field(_nombreCtrl, "Nombre completo"),
              _field(
                _correoCtrl,
                "Correo electrónico",
                TextInputType.emailAddress,
              ),
              _field(
                _celularCtrl,
                "Celular",
                TextInputType.phone,
              ),
              _field(
                _detalleCtrl,
                "Detalle del reclamo",
                TextInputType.multiline,
                4,
              ),
              _field(
                _pedidoCtrl,
                "Pedido o solución esperada",
                TextInputType.multiline,
                3,
              ),

              const SizedBox(height: 12),

              // ===== DECLARACIÓN =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grisSuave,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _acepto,
                      onChanged: (v) => setState(() => _acepto = v ?? false),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Declaro que la información proporcionada es verídica.",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== BOTÓN =====
              SizedBox(
                width: double.infinity,
                height: 56,
                child: _enviando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _enviar,
                        icon: const Icon(Icons.send),
                        label: const Text("Enviar reclamación"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, [
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: (v) =>
            v == null || v.isEmpty ? "Campo obligatorio" : null,
      ),
    );
  }
}
