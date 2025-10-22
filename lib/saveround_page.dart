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

  // === COLECCIÓN DE PERSONAL ACTUALIZADA ===
  final String _personalCollection = 'personal';
  // =========================================

  // === COLORES DEL DISEÑO UNIFICADO ===
  final Color primaryColor = const Color.fromARGB(255, 8, 148, 187);
  final Color secondaryColor = Colors.amber.shade700;
  final Color backgroundColor = Colors.blueGrey[50]!;

  DateTime? fechaInicio;
  // CAMBIO: vueltaSeleccionada -> horarioSeleccionado
  String? horarioSeleccionado;
  String? destinoSeleccionado;
  String? origenSeleccionado;

  List<String> guardias = [];
  List<String> guardiasDisponibles = [];
  bool loading = false;
  bool loadingGuardias = true;

  // CAMBIO: Se actualizan los rangos horarios completos
  final List<String> horariosDisponibles = [
    '08:00 a 16:00',
    '16:00 a 00:00',
    '08:00 a 18:00',
    '00:00 a 08:00',
  ];
  // =========================================

  final List<String> destinoDisponibles = [
    'Bodega Lourdes',
    'Centro de Investigacion'
  ];
  final List<String> origenDisponibles = ['Talca', 'Pencahue', 'Figueroa'];

  @override
  void initState() {
    super.initState();
    cargarGuardias();
  }

  @override
  void dispose() {
    _destinoController.dispose();
    super.dispose();
  }

  Future<void> cargarGuardias() async {
    try {
      final snapshot = await _firestore.collection(_personalCollection).get();
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        fechaInicio = date;
      });
    }
  }

  // === DIÁLOGO DE CONFIRMACIÓN CON INFORMACIÓN CARGADA (ACTUALIZADO para Horario) ===
  void _mostrarDialogoConfirmacion(BuildContext context, String origen,
      String destino, String horario, DateTime fecha, List<String> guardias) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: primaryColor, size: 30),
              SizedBox(width: 10),
              Text("¡Vuelta Registrada!"),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Has creado la vuelta correctamente. Los detalles son:",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text("Origen: $origen"),
                Text("Destino: $destino"),
                Text("Horario: $horario"), // CAMBIO: Usando Horario
                Text("Fecha: ${fecha.day}/${fecha.month}/${fecha.year}"),
                Text("Guardias: ${guardias.join(', ')}"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Aceptar",
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // ===================================================

  // === FUNCIÓN PARA LIMPIAR EL FORMULARIO (ACTUALIZADO para Horario) ===
  void resetForm() {
    _formKey.currentState!.reset(); // Limpia los DropdownFields
    setState(() {
      fechaInicio = null;
      guardias = [];
      // CAMBIO: vueltaSeleccionada -> horarioSeleccionado
      horarioSeleccionado = null;
      destinoSeleccionado = null;
      origenSeleccionado = null;
    });
    // Muestra una confirmación rápida
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Formulario limpiado."),
        duration: Duration(seconds: 1),
      ),
    );
  }
  // ===============================================

  Future<void> guardarVuelta() async {
    // 1. Validar el formulario (incluye origen, destino y horario)
    if (!_formKey.currentState!.validate()) return;

    // 2. Validaciones manuales (Guardias y Fecha)
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

    setState(() => loading = true);

    try {
      // Nota: El campo 'guardias' aquí guarda solo los NOMBRES.
      // Para tener el RUT y el HORARIO en el Historial, tendrías que:
      // 1. Buscar el RUT y el HORARIO para CADA guardia seleccionado en la colección 'personal'.
      // 2. Guardar un array de objetos en 'vueltas', no solo de strings.

      // Aquí guardamos el campo 'horario' con el rango de turno completo
      await _firestore.collection('vueltas').add({
        'chofer': _auth.currentUser!.uid,
        'origen': origenSeleccionado,
        'destino': destinoSeleccionado,
        'fechaInicio': fechaInicio,
        'horario': horarioSeleccionado, // CAMBIO: Guardando el HORARIO completo
        'guardias': guardias,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Mostrar el nuevo diálogo de confirmación, PASANDO los datos
      _mostrarDialogoConfirmacion(context, origenSeleccionado!,
          destinoSeleccionado!, horarioSeleccionado!, fechaInicio!, guardias);

      // 4. Limpiar campos
      resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  void goToHome() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/home');
  }

  void goToHistorial() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/historial');
  }

  void goToAgregarGuardia() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/agregarGuardia');
  }

  Widget _buildFormCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definición de estilo para los DropdownFields
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Registrar Nueva Vuelta"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
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
              leading: Icon(Icons.directions_car, color: secondaryColor),
              title: Text("Registrar Vuelta",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              selected: true,
              selectedTileColor: primaryColor.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
              },
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
                Navigator.pop(context);
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Cerrar sesión",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),

                // 1. TARJETA DE DESTINO Y HORARIO
                _buildFormCard(
                  title: "Origen, Destino y Horario",
                  content: Column(
                    children: [
                      // ORIGEN (CASILLA OBLIGATORIA)
                      DropdownButtonFormField<String>(
                        value: origenSeleccionado,
                        decoration:
                            inputDecoration.copyWith(labelText: "Origen"),
                        items: origenDisponibles
                            .map((o) =>
                                DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            origenSeleccionado = val;
                          });
                        },
                        validator: (val) =>
                            val == null ? "Selecciona el origen" : null,
                      ),
                      SizedBox(height: 16),
                      // DESTINO (CASILLA OBLIGATORIA)
                      DropdownButtonFormField<String>(
                        value: destinoSeleccionado,
                        decoration:
                            inputDecoration.copyWith(labelText: "Destino"),
                        items: destinoDisponibles
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d)))
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
                      // HORARIO (Rango de Turno Completo) (CASILLA OBLIGATORIA)
                      DropdownButtonFormField<String>(
                        // CAMBIO: vueltaSeleccionada -> horarioSeleccionado
                        value: horarioSeleccionado,
                        decoration: inputDecoration.copyWith(
                            labelText: "Rango Horario"),
                        // CAMBIO: vueltasDisponibles -> horariosDisponibles
                        items: horariosDisponibles
                            .map((h) =>
                                DropdownMenuItem(value: h, child: Text(h)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            // CAMBIO: vueltaSeleccionada -> horarioSeleccionado
                            horarioSeleccionado = val;
                          });
                        },
                        validator: (val) =>
                            val == null ? "Selecciona el horario" : null,
                      ),
                    ],
                  ),
                ),

                // 2. TARJETA DE FECHA (CASILLA OBLIGATORIA)
                _buildFormCard(
                  title: "Fecha de Inicio",
                  content: OutlinedButton.icon(
                    onPressed: pickFechaInicio,
                    icon: Icon(Icons.calendar_today, color: primaryColor),
                    label: Text(
                      fechaInicio == null
                          ? "Seleccionar fecha de inicio"
                          : "Fecha: ${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      side: BorderSide(color: primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

                // 3. TARJETA DE SELECCIÓN DE GUARDIAS
                _buildFormCard(
                  title: "Asignar Guardias (${guardias.length} seleccionados)",
                  content: loadingGuardias
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: guardiasDisponibles.map((g) {
                            final selected = guardias.contains(g);
                            return ChoiceChip(
                              label: Text(g),
                              selected: selected,
                              selectedColor: primaryColor.withOpacity(0.2),
                              labelStyle: TextStyle(
                                  color:
                                      selected ? primaryColor : Colors.black87,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                              side: BorderSide(
                                  color: selected ? primaryColor : Colors.grey,
                                  width: 1),
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
                ),

                SizedBox(height: 10),

                // Contenedor para los dos botones
                Row(
                  children: [
                    // BOTÓN LIMPIAR
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: loading ? null : resetForm,
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text("Limpiar"),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 55),
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Espacio entre botones
                    // BOTÓN GUARDAR
                    Expanded(
                      child: loading
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor))
                          : ElevatedButton.icon(
                              onPressed: guardarVuelta,
                              icon: Icon(Icons.save),
                              label: Text("Guardar"),
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
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
