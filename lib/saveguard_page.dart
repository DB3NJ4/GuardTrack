import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importante para el portapapeles
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgregarGuardiaPage extends StatefulWidget {
  @override
  _AgregarGuardiaPageState createState() => _AgregarGuardiaPageState();
}

class _AgregarGuardiaPageState extends State<AgregarGuardiaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // === COLORES DEL DISEÑO UNIFICADO ===
  final Color primaryColor =
      const Color.fromARGB(255, 8, 148, 187); // Celeste brillante
  final Color secondaryColor = Colors.amber.shade700; // Ámbar
  final Color backgroundColor = Colors.blueGrey[50]!; // Fondo Scaffold
  final Color deleteColor = Colors.red.shade700;
  final Color copyColor =
      Colors.green.shade700; // Color para el ícono de copiado

  bool loading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // === FUNCIÓN PARA COPIAR TELÉFONO ===
  Future<void> _copiarTelefono(String telefono) async {
    // Copia el texto al portapapeles del sistema
    await Clipboard.setData(ClipboardData(text: telefono));

    // Muestra una confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Teléfono '$telefono' copiado al portapapeles"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // === FUNCIONES DE NAVEGACIÓN ===
  void goToHome() {
    // Navegación forzada al home
    Navigator.pushReplacementNamed(context, '/home');
  }

  void goToAgregarVuelta() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/agregarVuelta');
  }

  void goToHistorial() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/historial');
  }

  // === FUNCIÓN PARA GUARDAR GUARDIA ===
  Future<void> guardarGuardia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      await _firestore.collection('guardias').add({
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(), // Permite cadena vacía
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Guardia agregado correctamente")),
      );

      _nombreController.clear();
      _telefonoController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // === FUNCIÓN PARA ELIMINAR GUARDIA ===
  Future<void> eliminarGuardia(String id) async {
    // NOTA: Se ha mantenido el uso de AlertDialog para confirmación,
    // ya que no estás en un entorno web que lo prohíba estrictamente
    // y es una práctica común en Flutter.
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Eliminación"),
        content: Text("¿Estás seguro de que quieres eliminar este guardia?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Eliminar", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: deleteColor),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('guardias').doc(id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Guardia eliminado")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar: $e")),
        );
      }
    }
  }

  // === FUNCIÓN PARA EDITAR GUARDIA (CON NUEVO ESTILO) ===
  Future<void> editarGuardia(
      String id, String nombreActual, String telefonoActual) async {
    final _editNombreController = TextEditingController(text: nombreActual);
    final _editTelefonoController = TextEditingController(text: telefonoActual);
    final _editFormKey = GlobalKey<FormState>();

    // Definición de estilo para inputs del diálogo
    final dialogInputDecoration = InputDecoration(
      labelText: "Nombre",
      labelStyle: TextStyle(color: primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Editar Guardia",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        content: Form(
          key: _editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _editNombreController,
                decoration: dialogInputDecoration.copyWith(labelText: "Nombre"),
                validator: (val) => val!.isEmpty
                    ? "Ingresa el nombre"
                    : null, // MANTENER OBLIGATORIO
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _editTelefonoController,
                keyboardType: TextInputType.phone,
                decoration: dialogInputDecoration.copyWith(
                    labelText: "Teléfono (Opcional)"),
                // MODIFICADO: Ahora el validador permite que el campo esté vacío
                validator: (val) {
                  // Si tiene valor, se podría añadir validación de formato aquí.
                  // Si está vacío, es válido (null).
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_editFormKey.currentState!.validate()) return;
              try {
                await _firestore.collection('guardias').doc(id).update({
                  'nombre': _editNombreController.text.trim(),
                  'telefono': _editTelefonoController.text
                      .trim(), // Permite cadena vacía
                  'timestamp': FieldValue.serverTimestamp(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Guardia actualizado")),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error al actualizar: $e")),
                );
              }
            },
            child: Text("Guardar"),
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // Widget para el formulario de adición
  Widget _buildAddFormCard(InputDecoration inputDecoration) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Registrar Nuevo Guardia",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: inputDecoration.copyWith(
                  labelText: "Nombre del Guardia",
                  prefixIcon:
                      Icon(Icons.person, color: primaryColor.withOpacity(0.7)),
                ),
                validator: (value) => value!.isEmpty
                    ? "Ingresa el nombre"
                    : null, // MANTENER OBLIGATORIO
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: inputDecoration.copyWith(
                  labelText: "Teléfono (Opcional)",
                  prefixIcon:
                      Icon(Icons.phone, color: primaryColor.withOpacity(0.7)),
                ),
                // MODIFICADO: Ahora el validador permite que el campo esté vacío
                validator: (value) => null,
              ),
              SizedBox(height: 24),
              loading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor))
                  : ElevatedButton.icon(
                      onPressed: guardarGuardia,
                      icon: Icon(Icons.add),
                      label: Text("Añadir Guardia"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 55),
                        textStyle: TextStyle(fontSize: 18),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Estilo unificado para los TextFormField
    final inputDecoration = InputDecoration(
      labelStyle: TextStyle(color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      // =========================================================
      // === DRAWER POSICIONADO A LA IZQUIERDA (Por defecto) ===
      // =========================================================
      drawer: Drawer(
        child: Column(
          children: [
            // Header del Drawer
            UserAccountsDrawerHeader(
              accountName: Text(_auth.currentUser?.displayName ?? "Chofer",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(_auth.currentUser?.email ?? ""),
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
              leading: Icon(Icons.home, color: primaryColor),
              title: Text("Inicio"),
              onTap: goToHome,
            ),
            ListTile(
              leading: Icon(Icons.directions_car, color: primaryColor),
              title: Text("Registrar Vuelta"),
              onTap: goToAgregarVuelta,
            ),
            ListTile(
              leading: Icon(Icons.history, color: primaryColor),
              title: Text("Ver Historial"),
              onTap: goToHistorial,
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt_1, color: secondaryColor),
              title: Text("Agregar Guardia",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              selected: true,
              selectedTileColor: primaryColor.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text("Configuración"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: deleteColor),
              title: Text("Cerrar sesión",
                  style: TextStyle(
                      color: deleteColor, fontWeight: FontWeight.bold)),
              onTap: () async {
                await _auth.signOut();
                // Asumiendo que '/' es la ruta de inicio de sesión
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Agregar/Gestionar Guardia"),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white), // Ícono de casa
            onPressed: goToHome, // Navega a '/home'
            tooltip: 'Ir a Inicio',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // CARD DE FORMULARIO DE ADICIÓN
              _buildAddFormCard(inputDecoration),

              // TÍTULO DE LA LISTA
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Guardias Registrados",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              // LISTA DE GUARDIAS (StreamBuilder)
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('guardias')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                        child: CircularProgressIndicator(color: primaryColor));

                  final guardias = snapshot.data!.docs;

                  if (guardias.isEmpty)
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                          "No hay guardias registrados. ¡Añade uno primero!",
                          style: TextStyle(color: Colors.grey[700])),
                    );

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: guardias.length,
                    itemBuilder: (context, index) {
                      final g = guardias[index];
                      // Asegúrate de manejar el caso en que 'telefono' pueda ser null o no exista si no se guardó antes
                      final telefono = g['telefono'] ?? "";

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: secondaryColor,
                            child: Text((index + 1).toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(g['nombre'],
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              "Teléfono: ${telefono.isEmpty ? 'N/A' : telefono}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // === BOTÓN DE COPIAR ===
                              IconButton(
                                icon: Icon(Icons.copy, color: copyColor),
                                onPressed: () => _copiarTelefono(telefono),
                                tooltip: "Copiar teléfono",
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryColor),
                                onPressed: () =>
                                    editarGuardia(g.id, g['nombre'], telefono),
                                tooltip: "Editar",
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: deleteColor),
                                onPressed: () => eliminarGuardia(g.id),
                                tooltip: "Eliminar",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
