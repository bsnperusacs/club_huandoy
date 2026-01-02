// 📁 lib/roles/padre/pantallas/pantalla_registro_padre.dart


import 'package:flutter/material.dart';
import 'package:club_huandoy/core/controladores/padre_controller.dart';
import 'package:club_huandoy/core/widgets/paso_identificacion.dart';
import 'package:club_huandoy/core/widgets/paso_contacto_ubicacion.dart';
import 'package:club_huandoy/core/widgets/paso_final.dart';
import 'package:club_huandoy/core/servicios/firestore_padre_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 AGREGA ESTO


class PantallaRegistroPadre extends StatefulWidget {
  const PantallaRegistroPadre({super.key});

  @override
  State<PantallaRegistroPadre> createState() => _PantallaRegistroPadreState();
}

class _PantallaRegistroPadreState extends State<PantallaRegistroPadre> {
  final PadreController controller = PadreController();
  final PageController pageCtrl = PageController();
  final FirestorePadreService firestoreService = FirestorePadreService();

  void next() => pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  void back() => pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  Future<void> _guardarFinal() async {
  await controller.guardarEnFirestore();
  await controller.enviarDatosAlCache();

  // ✅ MARCAR PERFIL COMO COMPLETO
  final uid = controller.uidActual;
  if (uid != null) {
    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .update({"registroCompleto": true});
  }


  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Registro guardado correctamente.")),
  );



  // ✅ VOLVER A LA PANTALLA DE INICIO
  await Future.delayed(const Duration(milliseconds: 500));

  Navigator.of(context).pushNamedAndRemoveUntil(
    '/inicio',
    (route) => false,
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Padre/Tutor")),
      body: PageView(
        controller: pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          PasoIdentificacion(controller: controller, onSiguiente: next),
          PasoContactoUbicacion(controller: controller, onAtras: back, onSiguiente: next),
          PasoFinal(controller: controller, onAtras: back, onGuardar: _guardarFinal),
        ],
      ),
    );
  }
}
