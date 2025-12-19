import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PantallaContacto extends StatelessWidget {
  const PantallaContacto({super.key});

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacto y Soporte"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Estamos para ayudarte 🤝",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "En el Club Deportivo Integral Huandoy queremos mejorar "
                    "cada día y sabemos que la mejor forma de hacerlo es "
                    "escuchándote. Si tienes dudas, sugerencias o necesitas "
                    "apoyo, puedes comunicarte con nosotros por los "
                    "siguientes medios oficiales.",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: Icon(Icons.phone, color: theme.colorScheme.primary),
              title: const Text("WhatsApp / Teléfono"),
              subtitle: const Text("+51 924 188 958"),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _abrirUrl("https://wa.me/51924188958"),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.email, color: theme.colorScheme.primary),
              title: const Text("Correo electrónico"),
              subtitle: const Text(
                  "club.deportivo.integral.huandoy.sacs@gmail.com"),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _abrirUrl(
                "mailto:club.deportivo.integral.huandoy.sacs@gmail.com",
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "💬 Sugerencias",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Queremos brindarte un mejor servicio y fortalecer "
                    "nuestra relación contigo y tu familia. "
                    "Tus sugerencias son muy importantes para nosotros.\n\n"
                    "Por favor, tómate un momento para enviarnos tus ideas, "
                    "comentarios o recomendaciones a través del formulario "
                    "de sugerencias. Escucharte nos ayuda a crecer.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
