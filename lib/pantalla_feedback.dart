import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaFeedback extends StatefulWidget {
  const PantallaFeedback({super.key});

  @override
  State<PantallaFeedback> createState() => _PantallaFeedbackState();
}

class _PantallaFeedbackState extends State<PantallaFeedback> {
  final TextEditingController _controller = TextEditingController();
  bool enviando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enviar Feedback"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cuéntanos qué está fallando o qué deberíamos mejorar:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // 📝 Caja de texto COMPLETAMENTE COMPATIBLE con Ñ y tildes
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                maxLines: 6,

                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,

                style: const TextStyle(
                  fontFamily: "Roboto", // usa Roboto que sí soporta ñ siempre
                  fontSize: 16,
                ),

                decoration: InputDecoration(
                  hintText: "Escribe tu comentario aquí...",
                  hintStyle: const TextStyle(fontFamily: "Roboto"),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // BOTÓN ENVIAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enviando ? null : _enviarFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Enviar Feedback",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarFeedback() async {
    final texto = _controller.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe algo antes de enviar.")),
      );
      return;
    }

    setState(() => enviando = true);

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('feedback').add({
      'uid': user?.uid,
      'email': user?.email,
      'mensaje': texto,
      'fecha': Timestamp.now(),
    });

    setState(() => enviando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Gracias por tu feedback ❤️"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
