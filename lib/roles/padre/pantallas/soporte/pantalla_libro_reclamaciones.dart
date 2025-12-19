import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

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
      const SnackBar(
        content: Text("Reclamación enviada correctamente"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                "Libro de Reclamaciones Virtual",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Este formulario permite registrar reclamos o quejas "
                "relacionadas con los servicios brindados por el "
                "Club Deportivo Integral Huandoy. "
                "La información será tratada de forma confidencial.",
              ),
              const SizedBox(height: 20),

              _field(_nombreCtrl, "Nombre completo"),
              _field(_correoCtrl, "Correo electrónico",
                  TextInputType.emailAddress),
              _field(_celularCtrl, "Celular", TextInputType.phone),
              _field(_detalleCtrl, "Detalle del reclamo",
                  TextInputType.multiline, 4),
              _field(_pedidoCtrl, "Pedido o solución esperada",
                  TextInputType.multiline, 3),

              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: _acepto,
                    onChanged: (v) => setState(() => _acepto = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      "Declaro que la información proporcionada es verídica.",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
        validator: (v) =>
            v == null || v.isEmpty ? "Campo obligatorio" : null,
      ),
    );
  }
}
