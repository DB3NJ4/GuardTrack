import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfigurationPage extends StatefulWidget {
  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  final _auth = FirebaseAuth.instance;
  User? user;

  // Colores principales
  final Color primaryColor = const Color.fromARGB(255, 8, 148, 187);
  final Color secondaryColor = Colors.amber.shade700;

  // Variables de configuración
  bool _notificacionesActivas = true;
  bool _modoOscuro = false;
  bool _localizacionActiva = true;
  String _idiomaSeleccionado = 'Español';
  String _temaSeleccionado = 'Azul Principal';

  final List<String> _idiomas = ['Español', 'English', 'Português'];
  final List<String> _temas = ['Azul Principal', 'Verde', 'Rojo', 'Morado'];

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    // Aquí cargarías las configuraciones guardadas
  }

  void _guardarConfiguracion() {
    // Lógica para guardar la configuración
    _mostrarMensaje('Configuración guardada exitosamente');
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: primaryColor,
      ),
    );
  }

  void _restablecerConfiguracion() {
    setState(() {
      _notificacionesActivas = true;
      _modoOscuro = false;
      _localizacionActiva = true;
      _idiomaSeleccionado = 'Español';
      _temaSeleccionado = 'Azul Principal';
    });
    _mostrarMensaje('Configuración restablecida');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Configuración"),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de información
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 40, color: primaryColor),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Configuración de la App",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Personalice su experiencia",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Configuraciones de la app
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Preferencias de la App",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Idioma
                    _buildConfigItem(
                      icon: Icons.language,
                      title: "Idioma",
                      subtitle: "Seleccione el idioma de la aplicación",
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _idiomaSeleccionado,
                          icon:
                              Icon(Icons.arrow_drop_down, color: primaryColor),
                          isExpanded: true,
                          items: _idiomas.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _idiomaSeleccionado = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    Divider(),

                    // Tema
                    _buildConfigItem(
                      icon: Icons.palette,
                      title: "Tema de colores",
                      subtitle: "Personalice los colores de la app",
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _temaSeleccionado,
                          icon:
                              Icon(Icons.arrow_drop_down, color: primaryColor),
                          isExpanded: true,
                          items: _temas.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _temaSeleccionado = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    Divider(),

                    // Modo oscuro
                    _buildConfigItem(
                      icon: Icons.dark_mode,
                      title: "Modo oscuro",
                      subtitle: "Activar interfaz en modo oscuro",
                      child: Switch(
                        value: _modoOscuro,
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _modoOscuro = value;
                          });
                        },
                      ),
                    ),

                    Divider(),

                    // Notificaciones
                    _buildConfigItem(
                      icon: Icons.notifications,
                      title: "Notificaciones",
                      subtitle: "Recibir notificaciones de la app",
                      child: Switch(
                        value: _notificacionesActivas,
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _notificacionesActivas = value;
                          });
                        },
                      ),
                    ),

                    Divider(),

                    // Localización
                    _buildConfigItem(
                      icon: Icons.location_on,
                      title: "Localización",
                      subtitle: "Usar ubicación para registros",
                      child: Switch(
                        value: _localizacionActiva,
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _localizacionActiva = value;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _restablecerConfiguracion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.grey[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text("RESTABLECER"),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardarConfiguracion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text("GUARDAR"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Información de la app
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Información de la App",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoItem("Versión", "1.0.0"),
                    _buildInfoItem("Desarrollador", "GuardTrack Team"),
                    _buildInfoItem("Usuario", user?.email ?? "No identificado"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
