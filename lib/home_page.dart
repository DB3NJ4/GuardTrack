import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Las importaciones de tus archivos originales (estos contienen las definiciones reales)
import 'package:guardtrack_app/saveround_page.dart';
import 'package:guardtrack_app/saveguard_page.dart';
import 'package:guardtrack_app/historial_page.dart';

// === CLASE HOMEPAGE CORREGIDA ===

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  User? user;

  // Colores principales para el nuevo diseño (Celeste brillante)
  final Color primaryColor = const Color.fromARGB(255, 8, 148, 187);
  final Color secondaryColor = Colors.amber.shade700;
  final Color thirdColor = const Color.fromARGB(255, 249, 250, 249);

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  void logout() async {
    await _auth.signOut();
    // Redirigir a la raíz de la aplicación (generalmente la página de login)
    Navigator.pushReplacementNamed(context, '/');
  }

  // Métodos de navegación
  // Importante: Asumimos que AgregarVueltaPage, AgregarGuardiaPage,
  // e HistorialVueltaPage están definidos en sus archivos importados.

  void goToRegistrarVuelta() {
    Navigator.pop(context); // Cierra el Drawer
    Navigator.push(
      context,
      // Usamos la clase importada desde saveround_page.dart
      MaterialPageRoute(builder: (context) => AgregarVueltaPage()),
    );
  }

  void goToAgregarGuardia() {
    Navigator.pop(context); // Cierra el Drawer
    Navigator.push(
      context,
      // Usamos la clase importada desde saveguard_page.dart
      MaterialPageRoute(builder: (context) => AgregarGuardiaPage()),
    );
  }

  void goToHistorial() {
    Navigator.pop(context); // Cierra el Drawer
    Navigator.push(
      context,
      // Usamos la clase importada desde historial_page.dart
      MaterialPageRoute(builder: (context) => HistorialVueltaPage()),
    );
  }

  // Widget para crear las tarjetas de menú en el body
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 7, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo muy claro
      appBar: AppBar(
        title: Text("GuardTrack Dashboard"),
        backgroundColor: primaryColor,
        elevation: 0, // Quitamos la sombra para un look más moderno
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.white,
            tooltip: "Cerrar sesión",
            onPressed: logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Header del Drawer con color principal
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "Chofer",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: secondaryColor,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              decoration: BoxDecoration(
                color: primaryColor,
              ),
            ),

            // Opciones de navegación
            ListTile(
              leading: Icon(Icons.add_road, color: primaryColor),
              title: Text("Registrar Vuelta"),
              onTap: goToRegistrarVuelta,
            ),
            ListTile(
              leading: Icon(Icons.history, color: primaryColor),
              title: Text("Ver historial"),
              onTap: goToHistorial,
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt_1, color: primaryColor),
              title: Text("Agregar Guardia"),
              onTap: goToAgregarGuardia,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text("Configuración"),
              onTap: () {
                Navigator.pop(context); // Cierra el Drawer
                // Implementar navegación a Configuración
              },
            ),
            Spacer(), // Empuja el botón de cerrar sesión hacia abajo
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text("Cerrar sesión",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: logout,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Bienvenida
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: thirdColor.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 40, color: primaryColor),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "¡Hola, ${user?.displayName ?? 'Chofer'}!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Gestión rápida de vueltas y personal.",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Título de la sección
            Text(
              "Opciones Rápidas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16),

            // Opciones de Menú en GridView (Dashboard)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Deshabilita el scroll del grid
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2, // Ajusta el tamaño de las tarjetas
              children: [
                _buildMenuCard(
                  title: "Registrar Vuelta",
                  subtitle: "Registra la vuelta de tu recorrido.",
                  icon: Icons.add_road,
                  color: primaryColor,
                  onTap: goToRegistrarVuelta,
                ),
                _buildMenuCard(
                  title: "Ver Historial",
                  subtitle: "Consulta todas las vueltas completadas.",
                  icon: Icons.history,
                  color: secondaryColor,
                  onTap: goToHistorial,
                ),
                _buildMenuCard(
                  title: "Agregar Guardia",
                  subtitle: "Registra un guardia de seguridad.",
                  icon: Icons.person_add_alt_1,
                  color: Colors.green.shade600,
                  onTap: goToAgregarGuardia,
                ),
                _buildMenuCard(
                  title: "Configuración",
                  subtitle: "Ajusta tus preferencias de la app.",
                  icon: Icons.settings,
                  color: Colors.grey.shade600,
                  onTap: () {
                    // Implementar navegación a Configuración
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
