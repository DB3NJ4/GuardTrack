import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardtrack_app/savesodexo_page.dart';
import 'package:guardtrack_app/saveroundsodexo_page.dart';
import 'package:guardtrack_app/historial_page.dart';
import 'package:guardtrack_app/configuration.dart';
import 'package:guardtrack_app/home_page.dart';
// Importación del componente CustomDrawer
import 'package:guardtrack_app/components/custom_drawer.dart';

class HistorialSodexoPage extends StatefulWidget {
  @override
  _HistorialSodexoPageState createState() => _HistorialSodexoPageState();
}

class _HistorialSodexoPageState extends State<HistorialSodexoPage> {
  // Instancias de Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // === ESTADO PARA LA EDICIÓN EN LÍNEA ===
  String? _editingDocId;
  Map<String, dynamic> _tempEditData = {};

  // Controlador para el campo de Trabajadores
  TextEditingController? _trabajadoresController;

  // === DATOS ESTATICOS PARA LAS OPCIONES DE EDICIÓN ===
  final List<String> _availableOrigenes = ['Talca', 'Pencahue', 'Figueroa'];
  final List<String> _availableDestinos = [
    'Bodega Lourdes',
    'Centro de Investigacion'
  ];
  final List<String> _availableHorarios = [
    '08:00 a 16:00',
    '16:00 a 00:00',
    '08:00 a 18:00',
    '00:00 a 08:00',
  ];

  // === COLORES DEL DISEÑO UNIFICADO ===
  final Color primaryColor = const Color.fromARGB(255, 8, 148, 187);
  final Color secondaryColor = Colors.amber;
  final Color backgroundColor = Colors.blueGrey[50]!;

  DateTime? filtroFecha;

  @override
  void dispose() {
    _trabajadoresController?.dispose();
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

  // === LÓGICA DE EDICIÓN EN LÍNEA ===

  void _startEditing(DocumentSnapshot vueltaDoc) {
    final data = vueltaDoc.data() as Map<String, dynamic>;

    // Convertir el campo 'trabajadores' a una sola cadena de texto para la edición
    final dynamic currentTrabajadoresValue = data['trabajadores'];
    String initialTrabajadores = '';

    if (currentTrabajadoresValue is List &&
        currentTrabajadoresValue.isNotEmpty) {
      initialTrabajadores = currentTrabajadoresValue.join(', ');
    } else if (currentTrabajadoresValue is String) {
      initialTrabajadores = currentTrabajadoresValue;
    }

    // Inicializa o recrea el controlador con el valor inicial
    _trabajadoresController?.dispose();
    _trabajadoresController = TextEditingController(text: initialTrabajadores);

    // Inicializamos _tempEditData con Origen, Destino y Horario
    _tempEditData = {
      'origen': data['origen'],
      'destino': data['destino'],
      'horario': data['horario'],
    };

    setState(() {
      _editingDocId = vueltaDoc.id;
    });
  }

  void _cancelEditing() {
    _trabajadoresController?.dispose();
    _trabajadoresController = null;

    setState(() {
      _editingDocId = null;
      _tempEditData = {};
    });
  }

  Future<void> _saveChanges(String docId) async {
    final updatedTrabajadores = _trabajadoresController?.text ?? '';

    if (_tempEditData['origen'] == null ||
        _tempEditData['destino'] == null ||
        _tempEditData['horario'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El origen, destino y el horario son obligatorios.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _firestore.collection('vueltas_sodexo').doc(docId).update({
        'origen': _tempEditData['origen'],
        'destino': _tempEditData['destino'],
        'horario': _tempEditData['horario'],
        'trabajadores': updatedTrabajadores,
      });
      _cancelEditing();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vuelta Sodexo actualizada con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error al actualizar la vuelta Sodexo: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la vuelta Sodexo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // === LÓGICA DE ELIMINACIÓN Y FILTROS ===

  Future<void> _confirmDelete(
      String docId, String destino, String horario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmar Eliminación"),
          content: Text(
              "¿Estás seguro de que quieres eliminar la vuelta Sodexo a $destino ($horario)? Esta acción es irreversible."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancelar", style: TextStyle(color: primaryColor)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 16)),
              child: Text("Eliminar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteVuelta(docId);
    }
  }

  Future<void> _deleteVuelta(String docId) async {
    try {
      await _firestore.collection('vueltas_sodexo').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vuelta Sodexo eliminada con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error al eliminar la vuelta Sodexo: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la vuelta Sodexo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> pickFiltroFecha() async {
    final date = await showDatePicker(
      context: context,
      initialDate: filtroFecha ?? DateTime.now(),
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
        .collection('vueltas_sodexo')
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

  Future<String> _getChoferName(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['displayName'] ?? doc.data()?['nombre'] ?? uid;
      }
      return uid;
    } catch (e) {
      print("Error al obtener nombre del chofer: $e");
      return uid;
    }
  }

  // === WIDGETS PARA LAS TARJETAS ===

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primaryColor),
          SizedBox(width: 8),
          Text(
            "$label: ",
            style:
                TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyCard(DocumentSnapshot v) {
    final docId = v.id;
    final origen = v['origen'] ?? 'N/A';
    final destino = v['destino'] ?? 'N/A';
    final horario = v['horario'] ?? 'N/A';

    // Manejo de 'trabajadores' como String o lista
    String trabajadoresDisplay;
    final dynamic trabajadoresValue = v['trabajadores'];
    if (trabajadoresValue is List) {
      trabajadoresDisplay = trabajadoresValue.join(', ');
    } else {
      trabajadoresDisplay = trabajadoresValue as String? ?? 'Ninguno';
    }

    final choferUid = v['chofer'] ?? 'Anonimo';
    final fechaTimestamp = v['fechaInicio'];
    final fechaDate =
        fechaTimestamp is Timestamp ? fechaTimestamp.toDate() : null;
    final fechaDisplay = fechaDate != null
        ? "${fechaDate.day}/${fechaDate.month}/${fechaDate.year}"
        : 'Fecha N/A';

    final isCurrentUser = _auth.currentUser?.uid == choferUid;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "$origen a $destino ($horario)",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge de Sodexo
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Chip(
                        label: Text("Sodexo",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.blue.shade700,
                      ),
                    ),
                    if (isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Chip(
                          label: Text("Mi Vuelta",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: secondaryColor,
                        ),
                      ),
                    if (isCurrentUser)
                      IconButton(
                        icon: Icon(Icons.edit, color: primaryColor),
                        onPressed: () => _startEditing(v),
                        tooltip: 'Editar esta vuelta Sodexo',
                      ),
                    if (isCurrentUser)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade700),
                        onPressed: () =>
                            _confirmDelete(docId, destino, horario),
                        tooltip: 'Eliminar esta vuelta Sodexo',
                      ),
                  ],
                ),
              ],
            ),
            Divider(height: 15, color: Colors.grey[300]),

            // Detalles de la Vuelta Sodexo
            _buildDetailRow(Icons.calendar_today, "Inicio", fechaDisplay),
            _buildDetailRow(Icons.location_city, "Origen", origen),
            _buildDetailRow(Icons.location_on, "Destino", destino),
            _buildDetailRow(
                Icons.people, "Trabajador(es)", trabajadoresDisplay),

            if (!isCurrentUser)
              FutureBuilder<String>(
                future: _getChoferName(choferUid),
                builder: (context, snapshot) {
                  final choferName = snapshot.data ?? 'Cargando Chofer...';
                  return _buildDetailRow(
                      Icons.person_pin, "Chofer", choferName);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingForm(String docId) {
    String? currentOrigen = _tempEditData['origen'] as String?;
    String? currentDestino = _tempEditData['destino'] as String?;
    String? currentHorario = _tempEditData['horario'] as String?;

    // Crear listas dinámicas que incluyan el valor actual si no está en las opciones estáticas
    List<String> dynamicOrigenes = List.from(_availableOrigenes);
    if (currentOrigen != null && !dynamicOrigenes.contains(currentOrigen)) {
      dynamicOrigenes.insert(0, currentOrigen);
    }

    List<String> dynamicDestinos = List.from(_availableDestinos);
    if (currentDestino != null && !dynamicDestinos.contains(currentDestino)) {
      dynamicDestinos.insert(0, currentDestino);
    }

    List<String> dynamicHorarios = List.from(_availableHorarios);
    if (currentHorario != null && !dynamicHorarios.contains(currentHorario)) {
      dynamicHorarios.insert(0, currentHorario);
    }

    if (_trabajadoresController == null) {
      _trabajadoresController = TextEditingController();
    }

    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: secondaryColor, width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Editando Vuelta Sodexo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                )),
            Divider(color: Colors.grey[300]),

            // Campo Origen
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Origen',
                icon: Icon(Icons.location_city, color: primaryColor),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              value: currentOrigen,
              items: dynamicOrigenes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _tempEditData['origen'] = newValue;
                });
              },
            ),
            SizedBox(height: 12),

            // Campo Destino
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Destino',
                icon: Icon(Icons.pin_drop, color: primaryColor),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              value: currentDestino,
              items: dynamicDestinos.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _tempEditData['destino'] = newValue;
                });
              },
            ),
            SizedBox(height: 12),

            // Campo Horario
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Horario',
                icon: Icon(Icons.access_time, color: primaryColor),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              value: currentHorario,
              items: dynamicHorarios.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _tempEditData['horario'] = newValue;
                });
              },
            ),
            SizedBox(height: 16),

            // Campo Trabajadores
            TextFormField(
              controller: _trabajadoresController,
              decoration: InputDecoration(
                labelText: 'Trabajadores Asignados (Separados por coma)',
                hintText: 'Escribe los nombres de los trabajadores',
                icon: Icon(Icons.people, color: primaryColor),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            SizedBox(height: 16),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancelEditing,
                  child: Text('Cancelar', style: TextStyle(color: Colors.red)),
                ),
                SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _saveChanges(docId),
                  icon: Icon(Icons.save),
                  label: Text('Guardar Cambios'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // =========================================================
      // === USANDO EL CUSTOM DRAWER ===
      // =========================================================
      drawer: CustomDrawer(
        context: context,
        currentPage: 'HistorialSodexo', // Identificador para esta página
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
      appBar: AppBar(
        title: Text("Historial de Vueltas Sodexo"),
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
        child: Column(
          children: [
            // FILTRO DE FECHA
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickFiltroFecha,
                        icon: Icon(Icons.calendar_today, color: primaryColor),
                        label: Text(
                          filtroFecha == null
                              ? "Filtrar por Fecha"
                              : "${filtroFecha!.day}/${filtroFecha!.month}/${filtroFecha!.year}",
                          style: TextStyle(color: primaryColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                    if (filtroFecha != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          icon: Icon(Icons.clear, color: Colors.red.shade700),
                          onPressed: clearFiltros,
                          tooltip: 'Quitar filtro de fecha',
                        ),
                      )
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // LISTADO DE VUELTAS SODEXO
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getVueltaStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(
                        child: CircularProgressIndicator(color: primaryColor));

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return Center(
                        child: Text(
                            "No hay vueltas Sodexo registradas para esta selección.",
                            style: TextStyle(color: Colors.grey.shade600)));

                  final vueltas = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: vueltas.length,
                    itemBuilder: (context, index) {
                      final v = vueltas[index];
                      final docId = v.id;

                      if (_editingDocId == docId) {
                        return _buildEditingForm(docId);
                      } else {
                        return _buildReadOnlyCard(v);
                      }
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
