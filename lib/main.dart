// 📁 lib/main.dart - CÓDIGO CORREGIDO

import 'package:flutter/material.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Localización
import 'package:flutter_localizations/flutter_localizations.dart';

// Provider
import 'package:provider/provider.dart';
import 'package:club_huandoy/core/providers/carrito_asignacion_provider.dart';

// Theme Global
import 'core/theme/app_theme.dart';

// Pantallas
import 'autenticacion/pantalla_login.dart';
import 'autenticacion/pantalla_registro.dart';
import 'autenticacion/pantalla_recuperar.dart';
import 'autenticacion/verificar_correo.dart';
import 'pantalla_inicio.dart';
import 'pantalla_feedback.dart';

// PADRE
import 'roles/padre/pantallas/matricula/pantalla_matricular_estudiante.dart';
import 'roles/padre/pantallas/pantalla_registro_padre.dart';
import 'roles/padre/pantallas/estudiantes_registrados.dart';

// PAGO
import 'roles/padre/pantallas/pago/pantalla_pagar_carrito.dart';

// ADMIN
import 'roles/admin/pantalla_admin_home.dart';

// Firebase Config
import 'firebase_options.dart';

// =========================================================================
// 🚀 FUNCIÓN MAIN CORREGIDA
// =========================================================================

Future<void> main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa Firebase antes de ejecutar la aplicación
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Ejecuta la aplicación UNA SOLA VEZ
  runApp(const ClubHuandoyApp());
}

// =========================================================================
// 🧩 CLASE PRINCIPAL
// =========================================================================

class ClubHuandoyApp extends StatelessWidget {
  const ClubHuandoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CarritoAsignacionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Club Deportivo Integral Huandoy',
        debugShowCheckedModeBanner: false,

        // ✔ THEME GLOBAL
        theme: AppTheme.light,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],

        initialRoute: '/',
        routes: {
          // CONTROL
          '/': (context) => const PantallaControl(),
          '/feedback': (context) => const PantallaFeedback(),

          // AUTENTICACIÓN
          '/login': (context) => const PantallaLogin(),
          '/registro': (context) => const PantallaRegistro(),
          '/recuperar': (context) => const PantallaRecuperar(),
          '/verificarCorreo': (context) => const PantallaVerificarCorreo(),

          // PADRE
          '/inicio': (context) => const PantallaInicio(),
          '/registroPadre': (context) => const PantallaRegistroPadre(),
          '/matricula': (context) => const PantallaMatriculaEstudiante(),
          '/estudiantesRegistrados': (context) => const EstudiantesRegistrados(),

          // PAGO
          '/pagarCarrito': (context) => const PantallaPagarCarrito(),
          "/carritoHorario": (context) => const PantallaPagarCarrito(),
          
          // ADMIN
          "/adminHome": (context) => PantallaAdminHome(),
        },
      ),
    );
  }
}

// =========================================================================
// 🔒 CONTROL SESIÓN + CORREO + ROL
// =========================================================================

/// CONTROL SESIÓN + CORREO + ROL
class PantallaControl extends StatelessWidget {
  const PantallaControl({super.key});

  Future<String> _leerRol(String uid) async {
    final snap =
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

    return snap.data()?['rol'] ?? 'padre';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Muestra el indicador de carga mientras espera el estado de autenticación.
        // Esto funciona como la pantalla de carga (Splash).
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // No autenticado
        if (user == null) return const PantallaLogin();

        // Correo no verificado
        if (!user.emailVerified) return const PantallaVerificarCorreo();

        // Leer rol
        return FutureBuilder<String>(
          future: _leerRol(user.uid),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final rol = snap.data;

            if (rol == 'admin') return const PantallaAdminHome();

            return const PantallaInicio();
          },
        );
      },
    );
  }
}