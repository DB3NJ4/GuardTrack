import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardtrack_app/saveround_page.dart';
import 'package:guardtrack_app/saveguard_page.dart';
import 'package:guardtrack_app/historial_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser; // Obtener usuario actual
  }

  void logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void goToRegistrarVuelta() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarVueltaPage()),
    );
  }

  void goToAgregarGuardia() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarGuardiaPage()),
    );
  }

  void goToHistorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistorialVueltaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("GuardTrack"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "Chofer"),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
              ),
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text("Registrar Vuelta"),
              onTap: goToRegistrarVuelta,
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Ver historial"),
              onTap: goToHistorial,
            ),
            ListTile(
              leading: Icon(Icons.shield),
              title: Text("Agregar Guardia"),
              onTap: goToAgregarGuardia,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Configuración"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                "Bienvenido, ${user?.displayName ?? 'Chofer'}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Correo: ${user?.email ?? ''}",
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: goToRegistrarVuelta, // Aquí redirige
                icon: Icon(Icons.add),
                label: Text("Registrar Vuelta"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
