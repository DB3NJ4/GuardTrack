import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// IMPORTACIONES DE TODAS LAS VISTAS
import 'package:guardtrack_app/savesodexo_page.dart';
import 'package:guardtrack_app/saveround_page.dart';
import 'package:guardtrack_app/saveguard_page.dart';
import 'package:guardtrack_app/historial_page.dart';
import 'package:guardtrack_app/configuration.dart';
import 'package:guardtrack_app/home_page.dart';
// Importación del componente CustomDrawer
import 'package:guardtrack_app/components/custom_drawer.dart';

class SaveRoundSodexoPage extends StatefulWidget {
  @override
  _SaveRoundSodexoPageState createState() => _SaveRoundSodexoPageState();
}

class _SaveRoundSodexoPageState extends State<SaveRoundSodexoPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // === COLECCIONES ===
  final String _trabajadoresCollection = 'trabajadores_sodexo';
  final String _vueltasCollection = 'vueltas_sodexo';

  // === COLORES DEL DISEÑO UNIFICADO ===
  final Color primaryColor = const Color.fromARGB(255, 8, 148, 187);
  final Color secondaryColor = Colors.amber;
  final Color backgroundColor = Colors.blueGrey[50]!;

  DateTime? fechaInicio;
  String? horarioSeleccionado;
  String? destinoSeleccionado;
  String? origenSeleccionado;

  List<String> trabajadores = [];
  List<String> trabajadoresDisponibles = [];
  bool loading = false;
  bool loadingTrabajadores = true;

  final List<String> horariosDisponibles = [
    '08:00 a 16:00',
    '16:00 a 00:00',
    '08:00 a 18:00',
    '00:00 a 08:00',
  ];

  final List<String> destinoDisponibles = [
    'Bodega Lourdes',
    'Centro de Investigacion'
  ];

  final List<String> origenDisponibles = ['Talca', 'Pencahue', 'Figueroa'];

  @override
  void initState() {
    super.initState();
    cargarTrabajadores();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // === MÉTODO PARA IR AL HOME ===
  void goToHome() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> cargarTrabajadores() async {
    try {
      final snapshot =
          await _firestore.collection(_trabajadoresCollection).get();
      setState(() {
        trabajadoresDisponibles =
            snapshot.docs.map((doc) => doc['nombre'].toString()).toList();
        loadingTrabajadores = false;
      });
    } catch (e) {
      setState(() => loadingTrabajadores = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar trabajadores: $e")));
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

  // === DIÁLOGO DE CONFIRMACIÓN ===
  void _mostrarDialogoConfirmacion(
      BuildContext context,
      String origen,
      String destino,
      String horario,
      DateTime fecha,
      List<String> trabajadores) {
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
              Text("¡Vuelta Sodexo Registrada!"),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "Has creado la vuelta Sodexo correctamente. Los detalles son:",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text("Origen: $origen"),
                Text("Destino: $destino"),
                Text("Horario: $horario"),
                Text("Fecha: ${fecha.day}/${fecha.month}/${fecha.year}"),
                Text("Trabajadores: ${trabajadores.join(', ')}"),
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

  // === FUNCIÓN PARA LIMPIAR EL FORMULARIO ===
  void resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      fechaInicio = null;
      trabajadores = [];
      horarioSeleccionado = null;
      destinoSeleccionado = null;
      origenSeleccionado = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Formulario limpiado."),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> guardarVuelta() async {
    if (!_formKey.currentState!.validate()) return;

    if (trabajadores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona al menos un trabajador")),
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
      await _firestore.collection(_vueltasCollection).add({
        'chofer': _auth.currentUser!.uid,
        'origen': origenSeleccionado,
        'destino': destinoSeleccionado,
        'fechaInicio': fechaInicio,
        'horario': horarioSeleccionado,
        'trabajadores': trabajadores,
        'empresa': 'Sodexo',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _mostrarDialogoConfirmacion(
          context,
          origenSeleccionado!,
          destinoSeleccionado!,
          horarioSeleccionado!,
          fechaInicio!,
          trabajadores);

      resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    } finally {
      setState(() => loading = false);
    }
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
      // =========================================================
      // === USANDO EL CUSTOM DRAWER ===
      // =========================================================
      drawer: CustomDrawer(
        context: context,
        currentPage: 'AgregarVueltaSodexo', // Identificador para esta página
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
      appBar: AppBar(
        title: Text("Registrar Vuelta Sodexo"),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),

                // 1. TARJETA DE ORIGEN, DESTINO Y HORARIO
                _buildFormCard(
                  title: "Origen, Destino y Horario",
                  content: Column(
                    children: [
                      // ORIGEN
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
                      // DESTINO
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
                      // HORARIO
                      DropdownButtonFormField<String>(
                        value: horarioSeleccionado,
                        decoration: inputDecoration.copyWith(
                            labelText: "Rango Horario"),
                        items: horariosDisponibles
                            .map((h) =>
                                DropdownMenuItem(value: h, child: Text(h)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            horarioSeleccionado = val;
                          });
                        },
                        validator: (val) =>
                            val == null ? "Selecciona el horario" : null,
                      ),
                    ],
                  ),
                ),

                // 2. TARJETA DE FECHA
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

                // 3. TARJETA DE SELECCIÓN DE TRABAJADORES
                _buildFormCard(
                  title:
                      "Asignar Trabajadores (${trabajadores.length} seleccionados)",
                  content: loadingTrabajadores
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor))
                      : trabajadoresDisponibles.isEmpty
                          ? Text(
                              "No hay trabajadores registrados. Agrega trabajadores primero.",
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: trabajadoresDisponibles.map((t) {
                                final selected = trabajadores.contains(t);
                                return ChoiceChip(
                                  label: Text(t),
                                  selected: selected,
                                  selectedColor: primaryColor.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                      color: selected
                                          ? primaryColor
                                          : Colors.black87,
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                  side: BorderSide(
                                      color:
                                          selected ? primaryColor : Colors.grey,
                                      width: 1),
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        trabajadores.add(t);
                                      } else {
                                        trabajadores.remove(t);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                ),

                SizedBox(height: 10),

                // BOTONES DE ACCIÓN
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
                    SizedBox(width: 10),
                    // BOTÓN GUARDAR
                    Expanded(
                      child: loading
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor))
                          : ElevatedButton.icon(
                              onPressed: guardarVuelta,
                              icon: Icon(Icons.save),
                              label: Text("Guardar Vuelta"),
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
