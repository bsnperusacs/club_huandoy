// 📁 lib/main.dart
import 'package:flutter/material.dart';
// ================= FIREBASE =================
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ================= LOCALIZACIÓN =================
import 'package:flutter_localizations/flutter_localizations.dart';
// ================= PROVIDER =================
import 'package:provider/provider.dart';
import 'package:club_huandoy/core/providers/carrito_asignacion_provider.dart';
// ================= THEME =================
import 'core/theme/app_theme.dart';
// ================= AUTH =================
import 'autenticacion/pantalla_login.dart';
import 'autenticacion/pantalla_registro.dart';
import 'autenticacion/pantalla_recuperar.dart';
import 'autenticacion/verificar_correo.dart';
// ================= GENERALES =================
import 'pantalla_inicio.dart';
import 'pantalla_feedback.dart';
// ================= PADRE =================
import 'roles/padre/pantallas/matricula/pantalla_matricular_estudiante.dart';
import 'roles/padre/pantallas/pantalla_registro_padre.dart';
import 'roles/padre/pantallas/estudiantes_registrados.dart';
import 'roles/padre/pantallas/pago/pantalla_pagar_carrito.dart';
// ================= SOPORTE =================
import 'roles/padre/pantallas/soporte/pantalla_soporte.dart';
import 'roles/padre/pantallas/soporte/pantalla_contacto.dart';
import 'roles/padre/pantallas/soporte/pantalla_sugerencias.dart';
import 'roles/padre/pantallas/soporte/pantalla_libro_reclamaciones.dart';
// ================= ADMIN =================
import 'roles/admin/pantalla_admin_home.dart';
import 'roles/admin/pantallas/disciplinas/admin_lista_disciplinas.dart';
import 'roles/admin/pantallas/disciplinas/admin_crear_disciplina.dart';
import 'roles/admin/pantallas/entrenadores/admin_lista_entrenadores.dart';
import 'roles/admin/pantallas/entrenadores/admin_crear_entrenador.dart';
import 'roles/admin/pantallas/grupos/admin_lista_grupos.dart';
import 'roles/admin/pantallas/grupos/admin_crear_grupo.dart';
import 'roles/admin/pantallas/horarios/admin_lista_horarios.dart';
import 'roles/admin/pantallas/horarios/admin_crear_horario.dart';
import 'roles/admin/pantallas/convenios/admin_lista_convenios.dart';
import 'roles/admin/pantallas/convenios/admin_crear_convenio.dart';

// ================= FIREBASE OPTIONS =================
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ClubHuandoyApp());
}

class ClubHuandoyApp extends StatelessWidget {
  const ClubHuandoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarritoAsignacionProvider()),
      ],
      child: MaterialApp(
        title: 'Club Deportivo Integral Huandoy',
        debugShowCheckedModeBanner: false,
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
          // ================= CONTROL =================
          '/': (context) => const PantallaControl(),

          // ================= AUTH =================
          '/login': (context) => const PantallaLogin(),
          '/registro': (context) => const PantallaRegistro(),
          '/recuperar': (context) => const PantallaRecuperar(),
          '/verificarCorreo': (context) => const PantallaVerificarCorreo(),

          // ================= GENERALES =================
          '/inicio': (context) => const PantallaInicio(),
          '/feedback': (context) => const PantallaFeedback(),

          // ================= PADRE =================
          '/registroPadre': (context) => const PantallaRegistroPadre(),
          '/matricula': (context) => const PantallaMatriculaEstudiante(),
          '/estudiantesRegistrados': (context) => const EstudiantesRegistrados(),

          // ================= PAGOS =================
          '/pagarCarrito': (context) => const PantallaPagarCarrito(),

          // ================= SOPORTE =================
          '/soporte': (context) => const PantallaSoporte(),
          '/soporteContacto': (context) => const PantallaContacto(),
          '/soporteSugerencias': (context) => PantallaSugerencias(),
          '/soporteReclamaciones': (context) =>
              const PantallaLibroReclamaciones(),

          // ================= ADMIN =================
          '/adminHome': (context) => PantallaAdminHome(),

          '/adminDisciplinas': (context) => AdminListaDisciplinas(),
          '/adminCrearDisciplina': (context) => AdminCrearDisciplina(),

          '/adminEntrenadores': (context) => AdminListaEntrenadores(),
          '/adminCrearEntrenador': (context) => AdminCrearEntrenador(),

          '/adminGrupos': (context) => AdminListaGrupos(),
          '/adminCrearGrupo': (context) => AdminCrearGrupo(),

          '/adminHorarios': (context) => AdminListaHorarios(),
          '/adminCrearHorario': (context) => AdminCrearHorario(),

          '/adminConvenios': (context) => AdminListaConvenios(),
          '/adminCrearConvenio': (context) => AdminCrearConvenio(),
        },
      ),
    );
  }
}

// ===============================
// 🔒 CONTROL SESIÓN + ROL
// ===============================
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const PantallaLogin();
        }

        if (!user.emailVerified) {
          return const PantallaVerificarCorreo();
        }

        return FutureBuilder<String>(
          future: _leerRol(user.uid),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return snap.data == 'admin'
                ? PantallaAdminHome()
                : const PantallaInicio();
          },
        );
      },
    );
  }
}
