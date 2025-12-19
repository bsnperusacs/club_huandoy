import 'package:flutter/material.dart';
import 'package:club_huandoy/core/theme/app_theme.dart';
import 'package:club_huandoy/core/theme/colores.dart';

class PantallaSoporte extends StatelessWidget {
  const PantallaSoporte({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Soporte y Ayuda"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== HEADER CON GRADIENT INSTITUCIONAL =====
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
                  size: 42,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Estamos para ayudarte",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Sugerencias, reclamos y contacto directo con el club.",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            "Opciones disponibles",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textoOscuro,
            ),
          ),
          const SizedBox(height: 12),

          _menuItem(
            context,
            icon: Icons.lightbulb_outline,
            title: "Enviar sugerencias",
            subtitle: "Ayúdanos a mejorar nuestros servicios.",
            route: '/soporteSugerencias',
          ),
          _menuItem(
            context,
            icon: Icons.menu_book_outlined,
            title: "Libro de reclamaciones",
            subtitle: "Registra un reclamo o queja formal.",
            route: '/soporteReclamaciones',
          ),
          _menuItem(
            context,
            icon: Icons.support_agent,
            title: "Contacto directo",
            subtitle: "WhatsApp y correo electrónico.",
            route: '/soporteContacto',
          ),
          _menuItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "Política de privacidad",
            subtitle: "Uso y protección de tu información.",
            route: '/politica',
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
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
          child: Icon(
            icon,
            color: AppColors.verde,
          ),
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
          style: const TextStyle(
            color: AppColors.textoOscuro,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
