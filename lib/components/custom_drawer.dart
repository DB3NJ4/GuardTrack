import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importaciones de todas las vistas
import 'package:guardtrack_app/saveroundsodexo_page.dart';
import 'package:guardtrack_app/savesodexo_page.dart';
import 'package:guardtrack_app/saveround_page.dart';
import 'package:guardtrack_app/saveguard_page.dart';
import 'package:guardtrack_app/historial_page.dart';
import 'package:guardtrack_app/historialsodexo_page.dart';
import 'package:guardtrack_app/configuration.dart';
import 'package:guardtrack_app/home_page.dart';

class CustomDrawer extends StatelessWidget {
  final BuildContext context;
  final String currentPage;
  final Color primaryColor;
  final Color secondaryColor;

  const CustomDrawer({
    Key? key,
    required this.context,
    required this.currentPage,
    this.primaryColor = const Color.fromARGB(255, 8, 148, 187),
    this.secondaryColor = Colors.amber,
  }) : super(key: key);

  // === MÉTODOS DE NAVEGACIÓN ===
  void _goToHome() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _goToAgregarVueltaSodexo() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaveRoundSodexoPage()),
    );
  }

  void _goToAgregarTrabajadorSodexo() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaveSodexoPage()),
    );
  }

  void _goToHistorialSodexo() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistorialSodexoPage()),
    );
  }

  void _goToRegistrarVueltaConchaToro() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarVueltaPage()),
    );
  }

  void _goToAgregarGuardiaConchaToro() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarGuardiaPage()),
    );
  }

  void _goToHistorialConchaToro() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistorialVueltaPage()),
    );
  }

  void _goToConfiguracion() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfigurationPage()),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  // === MÉTODO PARA VERIFICAR SI UNA PÁGINA ESTÁ SELECCIONADA ===
  bool _isSelected(String pageName) {
    return currentPage == pageName;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // CORRECCIÓN: Usar un color fijo para amber en lugar de shade700
    final amberColor = Color.fromARGB(255, 255, 193, 7); // Amber 700 aproximado

    return Drawer(
      child: Column(
        children: [
          // Header del Drawer
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "Chofer",
                style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: amberColor, // CORREGIDO: usar amberColor
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: primaryColor,
            ),
          ),

          // === SECCIÓN PRINCIPAL ===
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  "PRINCIPAL",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                Spacer(),
                Icon(Icons.home, color: primaryColor, size: 20),
              ],
            ),
          ),
          Divider(color: primaryColor, thickness: 1, height: 1),

          // Opción Home
          ListTile(
            leading: Icon(Icons.home, color: primaryColor),
            title: Text("Inicio"),
            selected: _isSelected('Home'),
            selectedTileColor: primaryColor.withOpacity(0.1),
            onTap: _goToHome,
          ),

          // === SECCIÓN SODEXO ===
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  "SODEXO",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                Spacer(),
                Icon(Icons.business_center, color: primaryColor, size: 20),
              ],
            ),
          ),
          Divider(color: primaryColor, thickness: 1, height: 1),

          // Opciones específicas de Sodexo
          ListTile(
            leading: Icon(Icons.add_road, color: primaryColor),
            title: Text("Agregar Vuelta"),
            selected: _isSelected('AgregarVueltaSodexo'),
            selectedTileColor: primaryColor.withOpacity(0.1),
            onTap: _goToAgregarVueltaSodexo,
          ),
          ListTile(
            leading: Icon(Icons.person_add_alt_1, color: primaryColor),
            title: Text("Agregar Trabajador"),
            selected: _isSelected('AgregarTrabajadorSodexo'),
            selectedTileColor: primaryColor.withOpacity(0.1),
            onTap: _goToAgregarTrabajadorSodexo,
          ),
          ListTile(
            leading: Icon(Icons.history, color: primaryColor),
            title: Text("Ver Historial Sodexo"),
            selected: _isSelected('HistorialSodexo'),
            selectedTileColor: primaryColor.withOpacity(0.1),
            onTap: _goToHistorialSodexo,
          ),

          // === SECCIÓN CONCHA Y TORO ===
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  "CONCHA Y TORO",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                Spacer(),
                Icon(Icons.wine_bar, color: primaryColor, size: 20),
              ],
            ),
          ),
          Divider(color: primaryColor, thickness: 1, height: 1),

          // Opciones específicas de Concha y Toro
          ListTile(
            leading: Icon(Icons.add_road, color: primaryColor),
            title: Text("Registrar Vuelta"),
            selected: _isSelected('RegistrarVueltaConchaToro'),
            selectedTileColor: primaryColor.withOpacity(0.1),
            onTap: _goToRegistrarVueltaConchaToro,
          ),
          ListTile(
            leading: Icon(Icons.person_add_alt_1, color: primaryColor),
            title: Text("Agregar Guardia"),
            selected: _isSelected('AgregarGuardiaConchaToro'),
            selectedTileColor: primaryColor.withOpacity(0.1),
            onTap: _goToAgregarGuardiaConchaToro,
          ),
          ListTile(
            leading: Icon(Icons.history, color: primaryColor),
            title: Text("Ver Historial"),
            selected: _isSelected('HistorialConchaToro'),
            selectedTileColor: primaryColor.withOpacity(0.1),
            onTap: _goToHistorialConchaToro,
          ),

          // === SECCIÓN OPCIONES ===
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  "OPCIONES",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                Spacer(),
                Icon(Icons.settings, color: primaryColor, size: 20),
              ],
            ),
          ),
          Divider(color: primaryColor, thickness: 1, height: 1),

          // Opciones de configuración
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey),
            title: Text("Configuración"),
            selected: _isSelected('Configuracion'),
            selectedTileColor: primaryColor.withOpacity(0.1),
            onTap: _goToConfiguracion,
          ),

          Spacer(),

          // Cerrar sesión
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text("Cerrar sesión",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: _logout,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
