import 'package:flutter/material.dart';
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

  bool loading = false;

  Future<void> guardarGuardia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      await _firestore.collection('guardias').add({
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
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

  Future<void> eliminarGuardia(String id) async {
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

  Future<void> editarGuardia(
      String id, String nombreActual, String telefonoActual) async {
    final _editNombreController = TextEditingController(text: nombreActual);
    final _editTelefonoController = TextEditingController(text: telefonoActual);
    final _editFormKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Guardia"),
        content: Form(
          key: _editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _editNombreController,
                decoration: InputDecoration(labelText: "Nombre"),
                validator: (val) => val!.isEmpty ? "Ingresa el nombre" : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _editTelefonoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Teléfono"),
                validator: (val) => val!.isEmpty ? "Ingresa el teléfono" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_editFormKey.currentState!.validate()) return;
              try {
                await _firestore.collection('guardias').doc(id).update({
                  'nombre': _editNombreController.text.trim(),
                  'telefono': _editTelefonoController.text.trim(),
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
          ),
        ],
      ),
    );
  }

  void goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void goToHistorial() {
    Navigator.pushReplacementNamed(context, '/historial');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Agregar Guardia"),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_auth.currentUser?.displayName ?? "Chofer"),
              accountEmail: Text(_auth.currentUser?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Inicio"),
              onTap: goToHome,
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text("Registrar Vuelta"),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/agregarVuelta'),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Ver Historial"),
              onTap: goToHistorial,
            ),
            ListTile(
              leading: Icon(Icons.shield),
              title: Text("Agregar Guardia"),
              selected: true,
              onTap: () {
                Navigator.pushNamed(context, '/agregarGuardia');
              },
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: "Nombre del Guardia",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Ingresa el nombre" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Teléfono",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Ingresa el teléfono" : null,
                    ),
                    SizedBox(height: 24),
                    loading
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: guardarGuardia,
                            icon: Icon(Icons.save),
                            label: Text("Guardar Guardia"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              textStyle: TextStyle(fontSize: 18),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Divider(),
              SizedBox(height: 16),
              Text(
                "Guardias Registrados",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800]),
              ),
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('guardias')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  final guardias = snapshot.data!.docs;

                  if (guardias.isEmpty)
                    return Text("No hay guardias registrados");

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: guardias.length,
                    itemBuilder: (context, index) {
                      final g = guardias[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(g['nombre']),
                          subtitle: Text("Telefono: ${g['telefono']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => editarGuardia(
                                    g.id, g['nombre'], g['telefono']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => eliminarGuardia(g.id),
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
