import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <-- generado por flutterfire
import 'login_page.dart';
import 'saveround_page.dart';
import 'saveguard_page.dart';
import 'home_page.dart';
import 'historial_page.dart';
import 'savesodexo_page.dart';
import 'saveroundsodexo_page.dart';
import 'configuration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase según la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GuardTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/agregarVuelta': (context) => AgregarVueltaPage(),
        '/agregarGuardia': (context) => AgregarGuardiaPage(),
        '/historial': (context) => HistorialVueltaPage(),
        '/guardarSodexo': (context) => SaveSodexoPage(),
        '/agregarVueltaSodexo': (context) => SaveRoundSodexoPage(),
        '/configuracion': (context) => ConfigurationPage(),
      },
    );
  }
}
