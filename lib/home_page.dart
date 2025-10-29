import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importaciones originales
import 'package:guardtrack_app/saveround_page.dart';
import 'package:guardtrack_app/saveguard_page.dart';
import 'package:guardtrack_app/historial_page.dart';
// Nuevas importaciones
import 'package:guardtrack_app/savesodexo_page.dart';
import 'package:guardtrack_app/saveroundsodexo_page.dart';
import 'package:guardtrack_app/historialsodexo_page.dart';
import 'package:guardtrack_app/configuration.dart';
// Importación del componente CustomDrawer
import 'package:guardtrack_app/components/custom_drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? user;

  // Colores principales para el nuevo diseño
  final Color primaryColor = const Color.fromARGB(255, 8, 148, 187);
  final Color secondaryColor = Color.fromARGB(255, 255, 193, 7); // Amber 700
  final Color backgroundColor = Colors.grey[50]!;
  final Color cardColor = Colors.white;

  // Variables para estadísticas reales
  int totalGuardias = 0;
  int totalTrabajadoresSodexo = 0;
  int vueltasHoy = 0;
  int vueltasSodexoHoy = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _cargarEstadisticas();
  }

  @override
  void dispose() {
    // Limpiar cualquier suscripción pendiente
    super.dispose();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      final hoy = DateTime.now();
      final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

      // Cargar conteo de guardias
      final guardiasSnapshot = await _firestore
          .collection('personal')
          .where('rol', isEqualTo: 'Guardia')
          .get();

      // Cargar conteo de trabajadores Sodexo
      final trabajadoresSnapshot =
          await _firestore.collection('trabajadores_sodexo').get();

      // Cargar vueltas de hoy (Concha y Toro)
      final vueltasHoySnapshot = await _firestore
          .collection('vueltas')
          .where('fechaInicio', isGreaterThanOrEqualTo: inicioDia)
          .where('fechaInicio', isLessThan: finDia)
          .get();

      // Cargar vueltas Sodexo de hoy
      final vueltasSodexoHoySnapshot = await _firestore
          .collection('vueltas_sodexo')
          .where('fechaInicio', isGreaterThanOrEqualTo: inicioDia)
          .where('fechaInicio', isLessThan: finDia)
          .get();

      // Solo actualizar si el widget todavía está montado
      if (mounted) {
        setState(() {
          totalGuardias = guardiasSnapshot.size;
          totalTrabajadoresSodexo = trabajadoresSnapshot.size;
          vueltasHoy = vueltasHoySnapshot.size;
          vueltasSodexoHoy = vueltasSodexoHoySnapshot.size;
          loading = false;
        });
      }
    } catch (e) {
      print("Error cargando estadísticas: $e");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  // ========== MÉTODOS DE NAVEGACIÓN ==========
  void goToRegistrarVueltaDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarVueltaPage()),
    );
  }

  void goToHistorialDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistorialVueltaPage()),
    );
  }

  void goToAgregarGuardiaDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarGuardiaPage()),
    );
  }

  void goToConfiguracionDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfigurationPage()),
    );
  }

  void goToAgregarVueltaSodexoDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaveRoundSodexoPage()),
    );
  }

  void goToAgregarTrabajadorSodexoDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaveSodexoPage()),
    );
  }

  void goToHistorialSodexoDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistorialSodexoPage()),
    );
  }

  // Widget para crear las tarjetas de menú mejoradas
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFeatured = false,
  }) {
    return Card(
      elevation: isFeatured ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cardColor,
            border: isFeatured
                ? Border.all(color: color.withOpacity(0.3), width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isFeatured) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "POPULAR",
                    style: TextStyle(
                      fontSize: 8,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget para estadísticas rápidas
  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shield, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              "GuardTrack",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // SOLO el botón de cerrar sesión
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar sesión",
            onPressed: logout,
          ),
        ],
      ),
      drawer: CustomDrawer(
        context: context,
        currentPage: 'Home',
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    "Cargando estadísticas...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de Bienvenida
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.9),
                          primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "¡Bienvenido!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                user?.displayName ?? 'Chofer',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Gestión de vueltas y personal",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.directions_car,
                              color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Estadísticas Rápidas
                  Text(
                    "Resumen del Día",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    children: [
                      _buildStatCard("$vueltasHoy", "Vueltas Hoy",
                          Icons.assignment_turned_in, Colors.green),
                      _buildStatCard("$totalGuardias", "Guardias",
                          Icons.people_alt, Colors.blue),
                      _buildStatCard("$totalTrabajadoresSodexo", "Trabajadores",
                          Icons.business_center, Colors.orange),
                      _buildStatCard("$vueltasSodexoHoy", "Vueltas Sodexo",
                          Icons.directions_car, Colors.purple),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Acciones Principales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Acciones Rápidas",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "MÁS USADAS",
                          style: TextStyle(
                            fontSize: 9,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _buildMenuCard(
                        title: "Registrar Vuelta",
                        subtitle: "Nuevo recorrido de seguridad",
                        icon: Icons.add_road,
                        color: primaryColor,
                        onTap: goToRegistrarVueltaDashboard,
                        isFeatured: true,
                      ),
                      _buildMenuCard(
                        title: "Ver Historial",
                        subtitle: "Vueltas completadas",
                        icon: Icons.history,
                        color: secondaryColor,
                        onTap: goToHistorialDashboard,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Gestión de Empresas
                  Text(
                    "Gestión por Empresa",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _buildMenuCard(
                        title: "Concha y Toro",
                        subtitle: "$totalGuardias guardias",
                        icon: Icons.wine_bar,
                        color: Colors.red.shade600,
                        onTap: goToAgregarGuardiaDashboard,
                      ),
                      _buildMenuCard(
                        title: "Sodexo",
                        subtitle: "$totalTrabajadoresSodexo trabajadores",
                        icon: Icons.business_center,
                        color: Colors.blue.shade600,
                        onTap: goToAgregarTrabajadorSodexoDashboard,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Otras Herramientas
                  Text(
                    "Más Herramientas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _buildMenuCard(
                        title: "Configuración",
                        subtitle: "Ajustes de la app",
                        icon: Icons.settings,
                        color: Colors.grey.shade600,
                        onTap: goToConfiguracionDashboard,
                      ),
                      _buildMenuCard(
                        title: "Vuelta Sodexo",
                        subtitle: "$vueltasSodexoHoy vueltas hoy",
                        icon: Icons.business,
                        color: Colors.purple.shade600,
                        onTap: goToAgregarVueltaSodexoDashboard,
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Espacio extra al final
                ],
              ),
            ),
    );
  }
}
