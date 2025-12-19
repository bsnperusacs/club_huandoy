import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:club_huandoy/core/theme/app_theme.dart';
import 'package:club_huandoy/core/theme/colores.dart';

class PantallaContacto extends StatelessWidget {
  const PantallaContacto({super.key});

  static const _telefono = '51924188958';

  Future<void> _abrirWhatsapp() async {
    final uri = Uri.parse('https://wa.me/$_telefono');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _abrirCorreo() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'club.deportivo.integral.huandoy.sacs@gmail.com',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          // HEADER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.headerGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Estamos para ayudarte",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Contacto directo con el club.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // WHATSAPP
          _contactCard(
            icon: Icons.phone,
            title: "WhatsApp",
            subtitle: "+51 924 188 958",
            onTap: _abrirWhatsapp,
          ),

          // CORREO
          _contactCard(
            icon: Icons.email,
            title: "Correo electrónico",
            subtitle:
                "club.deportivo.integral.huandoy.sacs@gmail.com",
            onTap: _abrirCorreo,
          ),

          const SizedBox(height: 24),

          // INFO
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sugerencias",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grisSuave,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.verde,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Tu opinión es clave para mejorar nuestros "
                            "servicios y fortalecer la relación con las "
                            "familias del club. Envíanos tus comentarios "
                            "desde la sección de sugerencias.",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.celeste.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.verde),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textoOscuro,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textoOscuro),
        ),
        trailing: const Icon(Icons.open_in_new),
        onTap: onTap,
      ),
    );
  }
}
