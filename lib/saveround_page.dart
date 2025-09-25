import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgregarVueltaPage extends StatefulWidget {
  @override
  _AgregarVueltaPageState createState() => _AgregarVueltaPageState();
}

class _AgregarVueltaPageState extends State<AgregarVueltaPage> {
  final _formKey = GlobalKey<FormState>();
  final _destinoController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DateTime? fechaInicio;
  String? vueltaSeleccionada;
  String? destinoSeleccionado;

  List<String> guardias = [];
  List<String> guardiasDisponibles = [];
  bool loading = false;
  bool loadingGuardias = true;

  final List<String> vueltasDisponibles = ['08:00', '16:00', '18:00', '00:00'];
  final List<String> destinoDisponibles = ['Bodega', 'CII'];

  @override
  void initState() {
    super.initState();
    cargarGuardias();
  }

  Future<void> cargarGuardias() async {
    try {
      final snapshot = await _firestore.collection('guardias').get();
      setState(() {
        guardiasDisponibles =
            snapshot.docs.map((doc) => doc['nombre'].toString()).toList();
        loadingGuardias = false;
      });
    } catch (e) {
      setState(() => loadingGuardias = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar guardias: $e")));
    }
  }

  Future<void> pickFechaInicio() async {
    final date = await showDatePicker(
      context: context,
      initialDate: fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        fechaInicio = date;
      });
    }
  }

  Future<void> guardarVuelta() async {
    if (!_formKey.currentState!.validate()) return;
    if (guardias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona al menos un guardia")),
      );
      return;
    }
    if (fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona la fecha de inicio")),
      );
      return;
    }
    if (vueltaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona la vuelta")),
      );
      return;
    }
    if (destinoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona el destino")),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await _firestore.collection('vueltas').add({
        'chofer': _auth.currentUser!.uid,
        'origen': 'Talca', // origen fijo
        'destino': destinoSeleccionado,
        'fechaInicio': fechaInicio,
        'vuelta': vueltaSeleccionada,
        'guardias': guardias,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vuelta registrada correctamente")),
      );

      _formKey.currentState!.reset();
      setState(() {
        fechaInicio = null;
        guardias = [];
        vueltaSeleccionada = null;
        destinoSeleccionado = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    } finally {
      setState(() => loading = false);
    }
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
        title: Text("Agregar Vuelta"),
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
              selected: true,
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Ver historial"),
              onTap: goToHistorial,
            ),
            ListTile(
              leading: Icon(Icons.shield),
              title: Text("Agregar Guardia"),
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // DESTINO
                DropdownButtonFormField<String>(
                  value: destinoSeleccionado,
                  decoration: InputDecoration(
                    labelText: "Destino",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: destinoDisponibles
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      destinoSeleccionado = val;
                    });
                  },
                  validator: (val) =>
                      val == null ? "Selecciona el destino" : null,
                ),
                SizedBox(height: 16),
                // FECHA
                OutlinedButton(
                  onPressed: pickFechaInicio,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    fechaInicio == null
                        ? "Seleccionar fecha de inicio"
                        : "${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 16),
                // VUELTA
                DropdownButtonFormField<String>(
                  value: vueltaSeleccionada,
                  decoration: InputDecoration(
                    labelText: "Vuelta",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: vueltasDisponibles
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      vueltaSeleccionada = val;
                    });
                  },
                  validator: (val) =>
                      val == null ? "Selecciona la vuelta" : null,
                ),
                SizedBox(height: 16),
                // GUARDIAS
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Guardias",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                loadingGuardias
                    ? CircularProgressIndicator()
                    : Wrap(
                        spacing: 8,
                        children: guardiasDisponibles.map((g) {
                          final selected = guardias.contains(g);
                          return ChoiceChip(
                            label: Text(g),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  guardias.add(g);
                                } else {
                                  guardias.remove(g);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                SizedBox(height: 24),
                loading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: guardarVuelta,
                        icon: Icon(Icons.save),
                        label: Text("Guardar Vuelta"),
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
        ),
      ),
    );
  }
}
