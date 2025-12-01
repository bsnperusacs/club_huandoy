// lib/opciones_firebase.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyDn3ja097qL2-NMQmU9YQyVm5tKHNcLAt4",
  authDomain: "clubdeportivohuandoy.firebaseapp.com",
  projectId: "clubdeportivohuandoy",
  storageBucket: "clubdeportivohuandoy.appspot.com",
  messagingSenderId: "292933443019",
  appId: "1:292933443019:web:221777f25751f1bfc26a4e",
  measurementId: "G-MKEVKCLHM7",
);

Future<void> inicializarFirebase() async {
  await Firebase.initializeApp(options: firebaseConfig);
  if (kDebugMode) {
    print('✅ Firebase inicializado correctamente');
  }
}
