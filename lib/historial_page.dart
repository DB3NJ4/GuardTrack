import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialVueltaPage extends StatefulWidget {
  @override
  _HistorialVueltaPageState createState() => _HistorialVueltaPageState();
}

class _HistorialVueltaPageState extends State<HistorialVueltaPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DateTime? filtroFecha;

  Future<void> pickFiltroFecha() async {
    final date = await showDatePicker(
      context: context,
      initialDate: filtroFecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        filtroFecha = date;
      });
    }
  }

  void clearFiltros() {
    setState(() {
      filtroFecha = null;
    });
  }

  Stream<QuerySnapshot> getVueltaStream() {
    Query query = _firestore
        .collection('vueltas')
        .orderBy('fechaInicio', descending: true);

    if (filtroFecha != null) {
      final start =
          DateTime(filtroFecha!.year, filtroFecha!.month, filtroFecha!.day);
      final end = start.add(Duration(days: 1));

      query = query
          .where('fechaInicio', isGreaterThanOrEqualTo: start)
          .where('fechaInicio', isLessThan: end);
    }

    return query.snapshots();
  }

  void goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Historial de Vueltas"),
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
              title: Text("Ver historial"),
              selected: true,
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.shield),
              title: Text("Agregar Guardia"),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/agregarGuardia'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtro por fecha
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickFiltroFecha,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      filtroFecha == null
                          ? "Filtrar por fecha"
                          : "${filtroFecha!.day}/${filtroFecha!.month}/${filtroFecha!.year}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.red),
                  onPressed: clearFiltros,
                )
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getVueltaStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return Center(child: Text("No hay vueltas registradas"));

                  final vueltas = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: vueltas.length,
                    itemBuilder: (context, index) {
                      final v = vueltas[index];
                      final origen = v['origen'] ?? '';
                      final destino = v['destino'] ?? '';
                      final guardias = List<String>.from(v['guardias'] ?? []);
                      final fecha = v['fechaInicio'] != null
                          ? (v['fechaInicio'] as Timestamp).toDate()
                          : null;

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Origen: $origen",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("Destino: $destino",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              if (fecha != null)
                                Text(
                                    "Fecha: ${fecha.day}/${fecha.month}/${fecha.year}"),
                              Text("Guardias: ${guardias.join(', ')}"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
