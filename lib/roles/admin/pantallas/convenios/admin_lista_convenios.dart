//📁 lib/roles/admin/pantallas/convenios/admin_lista_convenios.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/controladores/convenios_controller.dart';
import '../../../../core/modelos/convenio_model.dart';
import 'admin_crear_convenio.dart';

class AdminListaConvenios extends StatelessWidget {
  final controller = ConveniosController();

  AdminListaConvenios({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Convenios"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminCrearConvenio()));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.listarConvenios(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No hay convenios creados"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final conven = ConvenioModel.fromFirestore(docs[i]);

              return Card(
                child: ListTile(
                  title: Text(conven.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "Código: ${conven.codigo}\nAplica en: ${conven.aplicaEn}\nDescuento: ${conven.valorDescuento}${conven.tipoDescuento == "porcentaje" ? "%" : " soles"}"),

                  trailing: Switch(
                    value: conven.activo,
                    onChanged: (v) {
                      if (v) {
                        controller.activar(conven.id);
                      } else {
                        controller.desactivar(conven.id);
                      }
                    },
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminCrearConvenio(convenioExistente: conven),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
