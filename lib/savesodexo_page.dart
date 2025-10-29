import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// IMPORTACIONES DE TODAS LAS VISTAS
import 'package:guardtrack_app/saveroundsodexo_page.dart';
import 'package:guardtrack_app/saveround_page.dart';
import 'package:guardtrack_app/saveguard_page.dart';
import 'package:guardtrack_app/historial_page.dart';
import 'package:guardtrack_app/configuration.dart';
import 'package:guardtrack_app/home_page.dart';
// Importación del componente CustomDrawer
import 'package:guardtrack_app/components/custom_drawer.dart';

class SaveSodexoPage extends StatefulWidget {
  @override
  _SaveSodexoPageState createState() => _SaveSodexoPageState();
}

class _SaveSodexoPageState extends State<SaveSodexoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _rutController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Colección para trabajadores Sodexo
  static const String _trabajadoresCollection = 'trabajadores_sodexo';

  // === COLORES DEL DISEÑO UNIFICADO ===
  final Color primaryColor = const Color.fromARGB(255, 8, 148, 187);
  final Color secondaryColor = Colors.amber.shade700;
  final Color backgroundColor = Colors.blueGrey[50]!;
  final Color deleteColor = Colors.red.shade700;
  final Color copyColor = Colors.green.shade700;

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // === FUNCIÓN PARA COPIAR TELÉFONO ===
  Future<void> _copiarTelefono(String telefono) async {
    await Clipboard.setData(ClipboardData(text: telefono));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Teléfono '$telefono' copiado al portapapeles"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // === MÉTODO PARA IR AL HOME ===
  void goToHome() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  // === FUNCIÓN PARA GUARDAR TRABAJADOR SODEXO ===
  Future<void> guardarTrabajador() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      await _firestore.collection(_trabajadoresCollection).add({
        'nombre': _nombreController.text.trim(),
        'rut': _rutController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'empresa': 'Sodexo',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trabajador Sodexo agregado correctamente")),
      );

      _nombreController.clear();
      _rutController.clear();
      _telefonoController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // === FUNCIÓN PARA ELIMINAR TRABAJADOR ===
  Future<void> eliminarTrabajador(String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Eliminación"),
        content: Text("¿Estás seguro de que quieres eliminar este trabajador?"),
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
        await _firestore.collection(_trabajadoresCollection).doc(id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Trabajador eliminado")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar: $e")),
        );
      }
    }
  }

  // === FUNCIÓN PARA EDITAR TRABAJADOR ===
  Future<void> editarTrabajador(
    String id,
    String nombreActual,
    String rutActual,
    String telefonoActual,
  ) async {
    final _editNombreController = TextEditingController(text: nombreActual);
    final _editRutController = TextEditingController(text: rutActual);
    final _editTelefonoController = TextEditingController(text: telefonoActual);
    final _editFormKey = GlobalKey<FormState>();

    final dialogInputDecoration = InputDecoration(
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
        title: Text("Editar Trabajador Sodexo",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        content: Form(
          key: _editFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CAMPO NOMBRE
                TextFormField(
                  controller: _editNombreController,
                  decoration:
                      dialogInputDecoration.copyWith(labelText: "Nombre"),
                  validator: (val) => val!.isEmpty ? "Ingresa el nombre" : null,
                ),
                SizedBox(height: 16),
                // CAMPO RUT (OPCIONAL)
                TextFormField(
                  controller: _editRutController,
                  keyboardType: TextInputType.text,
                  decoration: dialogInputDecoration.copyWith(
                      labelText: "RUT (Opcional)"),
                ),
                SizedBox(height: 16),
                // CAMPO TELÉFONO (OPCIONAL)
                TextFormField(
                  controller: _editTelefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: dialogInputDecoration.copyWith(
                      labelText: "Teléfono (Opcional)"),
                ),
              ],
            ),
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
                await _firestore
                    .collection(_trabajadoresCollection)
                    .doc(id)
                    .update({
                  'nombre': _editNombreController.text.trim(),
                  'rut': _editRutController.text.trim(),
                  'telefono': _editTelefonoController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Trabajador actualizado")),
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
                "Registrar Nuevo Trabajador Sodexo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 16),
              // CAMPO NOMBRE (OBLIGATORIO)
              TextFormField(
                controller: _nombreController,
                decoration: inputDecoration.copyWith(
                  labelText: "Nombre Completo",
                  prefixIcon:
                      Icon(Icons.person, color: primaryColor.withOpacity(0.7)),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Ingresa el nombre" : null,
              ),
              SizedBox(height: 16),
              // CAMPO RUT (OPCIONAL)
              TextFormField(
                controller: _rutController,
                keyboardType: TextInputType.text,
                decoration: inputDecoration.copyWith(
                  labelText: "RUT (Opcional)",
                  prefixIcon:
                      Icon(Icons.badge, color: primaryColor.withOpacity(0.7)),
                ),
              ),
              SizedBox(height: 16),
              // CAMPO TELÉFONO (OPCIONAL)
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: inputDecoration.copyWith(
                  labelText: "Teléfono (Opcional)",
                  prefixIcon:
                      Icon(Icons.phone, color: primaryColor.withOpacity(0.7)),
                ),
              ),
              SizedBox(height: 24),
              loading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor))
                  : ElevatedButton.icon(
                      onPressed: guardarTrabajador,
                      icon: Icon(Icons.add),
                      label: Text("Añadir Trabajador"),
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
      // === USANDO EL CUSTOM DRAWER ===
      // =========================================================
      drawer: CustomDrawer(
        context: context,
        currentPage:
            'AgregarTrabajadorSodexo', // Identificador para esta página
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
      appBar: AppBar(
        title: Text("Agregar/Gestionar Trabajadores Sodexo"),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: goToHome,
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
                  "Trabajadores Sodexo Registrados",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              // LISTA DE TRABAJADORES (StreamBuilder)
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection(_trabajadoresCollection)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                        child: CircularProgressIndicator(color: primaryColor));

                  final trabajadores = snapshot.data!.docs;

                  if (trabajadores.isEmpty)
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                          "No hay trabajadores registrados. ¡Añade uno primero!",
                          style: TextStyle(color: Colors.grey[700])),
                    );

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: trabajadores.length,
                    itemBuilder: (context, index) {
                      final t = trabajadores[index];
                      final telefono = t['telefono'] ?? "";
                      final rut = t['rut'] ?? "";

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
                          title: Text(t['nombre'],
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (rut.isNotEmpty) Text("RUT: $rut"),
                              Text(
                                  "Teléfono: ${telefono.isEmpty ? 'N/A' : telefono}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // BOTÓN DE COPIAR (solo si hay teléfono)
                              if (telefono.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.copy, color: copyColor),
                                  onPressed: () => _copiarTelefono(telefono),
                                  tooltip: "Copiar teléfono",
                                ),
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryColor),
                                onPressed: () => editarTrabajador(
                                    t.id, t['nombre'], rut, telefono),
                                tooltip: "Editar",
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: deleteColor),
                                onPressed: () => eliminarTrabajador(t.id),
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
