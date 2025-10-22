import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardtrack_app/saveguard_page.dart';
import 'package:guardtrack_app/saveround_page.dart';
import 'package:guardtrack_app/home_page.dart';

// =================================================================
// CLASE TEMPORAL PARA SIMULAR LAS OTRAS PÁGINAS DEL DRAWER
// Reemplaza esta clase con tus páginas reales (e.g., HomePage, AgregarVueltaPage)
// cuando las tengas creadas.
// =================================================================
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 8, 148, 187),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: Colors.amber.shade700),
              const SizedBox(height: 20),
              Text(
                'Página de "$title" en Construcción',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Esta es una página temporal para validar la navegación del Drawer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// =================================================================
// *** SE ELIMINARON LAS CLASES TEMPORALES DUPLICADAS QUE CAUSABAN EL CONFLICTO ***
// =================================================================

class HistorialVueltaPage extends StatefulWidget {
  @override
  _HistorialVueltaPageState createState() => _HistorialVueltaPageState();
}

class _HistorialVueltaPageState extends State<HistorialVueltaPage> {
  // Instancias de Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // === ESTADO PARA LA EDICIÓN EN LÍNEA ===
  String? _editingDocId;
  Map<String, dynamic> _tempEditData = {};

  // FIX: Controlador para el campo de Guardia para evitar que el teclado se cierre
  TextEditingController? _guardiaController;

  // === DATOS ESTATICOS PARA LAS OPCIONES DE EDICIÓN ===
  final List<String> _availableOrigenes = [
    'Talca',
    'Pencahue',
    'Figueroa',
  ]; // <<< Orígenes disponibles
  final List<String> _availableDestinos = [
    'Bodega Lourdes',
    'Centro de Investigacion',
  ];
  final List<String> _availableVueltas = [
    '08:00 a 16:00',
    '16:00 a 00:00',
    '08:00 a 18:00',
    '00:00 a 08:00',
  ];

  // === COLORES DEL DISEÑO UNIFICADO ===
  final Color primaryColor = const Color.fromARGB(255, 8, 148, 187);
  final Color secondaryColor = Colors.amber.shade700;
  final Color backgroundColor = Colors.blueGrey[50]!;

  DateTime? filtroFecha; // Estado para el filtro de fecha

  @override
  void dispose() {
    // Es crucial liberar el controlador de memoria
    _guardiaController?.dispose();
    super.dispose();
  }

  // === LÓGICA DE EDICIÓN EN LÍNEA ===

  // 1. Inicia el modo de edición para un documento.
  void _startEditing(DocumentSnapshot vueltaDoc) {
    final data = vueltaDoc.data() as Map<String, dynamic>;

    // Convertir el campo 'guardias' a una sola cadena de texto para la edición.
    final dynamic currentGuardValue = data['guardias'];
    String initialGuardia = '';

    if (currentGuardValue is List && currentGuardValue.isNotEmpty) {
      initialGuardia = currentGuardValue.join(', ');
    } else if (currentGuardValue is String) {
      initialGuardia = currentGuardValue;
    }

    // Inicializa o recrea el controlador con el valor inicial
    _guardiaController?.dispose();
    _guardiaController = TextEditingController(text: initialGuardia);

    // Inicializamos _tempEditData con Origen, Destino y Vuelta
    _tempEditData = {
      'origen': data['origen'], // <<< LEYENDO EL ORIGEN
      'destino': data['destino'],
      'vuelta': data['vuelta'],
    };

    setState(() {
      _editingDocId = vueltaDoc.id;
    });
  }

  // 2. Cancela el modo de edición y limpia los datos temporales.
  void _cancelEditing() {
    // Libera y nulifica el controlador
    _guardiaController?.dispose();
    _guardiaController = null;

    setState(() {
      _editingDocId = null;
      _tempEditData = {};
    });
  }

  // 3. Guarda los cambios en Firestore.
  Future<void> _saveChanges(String docId) async {
    // 1. OBTENER el valor de guardia DIRECTAMENTE del controlador
    final updatedGuardia = _guardiaController?.text ?? '';

    // 2. Validar Origen, Destino y Vuelta
    if (_tempEditData['origen'] == null || // <<< VALIDANDO EL ORIGEN
        _tempEditData['destino'] == null ||
        _tempEditData['vuelta'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('El origen, destino y el tipo de vuelta son obligatorios.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _firestore.collection('vueltas').doc(docId).update({
        'origen': _tempEditData['origen'], // <<< GUARDANDO EL ORIGEN
        'destino': _tempEditData['destino'],
        'vuelta': _tempEditData['vuelta'],
        'guardias': updatedGuardia, // Usamos el valor del controlador
      });
      _cancelEditing(); // Salir del modo de edición
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vuelta actualizada con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error al actualizar la vuelta: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la vuelta.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // === LÓGICA DE ELIMINACIÓN Y FILTROS ===

  // Muestra un diálogo de confirmación antes de eliminar.
  Future<void> _confirmDelete(
      String docId, String destino, String vuelta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmar Eliminación"),
          content: Text(
              "¿Estás seguro de que quieres eliminar la vuelta a $destino ($vuelta)? Esta acción es irreversible."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancelar
              child: Text("Cancelar", style: TextStyle(color: primaryColor)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true), // Eliminar
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

  // Ejecuta la eliminación en Firestore.
  Future<void> _deleteVuelta(String docId) async {
    try {
      await _firestore.collection('vueltas').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vuelta eliminada con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error al eliminar la vuelta: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la vuelta.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Muestra el selector de fecha para el filtro.
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

  // Limpia el filtro de fecha.
  void clearFiltros() {
    setState(() {
      filtroFecha = null;
    });
  }

  // Genera el Stream de Query para Firestore, aplicando filtros si existen.
  Stream<QuerySnapshot> getVueltaStream() {
    Query query = _firestore
        .collection('vueltas')
        .orderBy('fechaInicio', descending: true);

    if (filtroFecha != null) {
      // Define el rango de 24 horas para el día seleccionado
      final start =
          DateTime(filtroFecha!.year, filtroFecha!.month, filtroFecha!.day);
      final end = start.add(Duration(days: 1));

      query = query
          .where('fechaInicio', isGreaterThanOrEqualTo: start)
          .where('fechaInicio', isLessThan: end);
    }

    return query.snapshots();
  }

  // Obtiene el nombre legible del chofer a partir de su UID.
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

  // === FUNCIONES DE NAVEGACIÓN ACTUALIZADAS ===

  void goToHome() {
    // Navegación forzada al home
    Navigator.pushReplacementNamed(context, '/home');
  }

  void goToRegistrarVuelta() {
    Navigator.pop(context); // Cierra el Drawer
    // Usamos la clase importada (AgregarVueltaPage)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarVueltaPage()),
    );
  }

  void goToAgregarGuardia() {
    Navigator.pop(context); // Cierra el Drawer
    // Usamos la clase importada (AgregarGuardiaPage)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarGuardiaPage()),
    );
  }

  // Widget auxiliar para mostrar una fila de detalle
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

  // === WIDGET PARA LA VISTA NORMAL (Solo Lectura) ===
  Widget _buildReadOnlyCard(DocumentSnapshot v) {
    final docId = v.id;
    final origen = v['origen'] ?? 'N/A'; // <<< LEYENDO EL ORIGEN
    final destino = v['destino'] ?? 'N/A';
    final vuelta = v['horario'] ?? 'N/A';

    // Manejo de 'guardias' como String o lista
    String guardiasDisplay;
    final dynamic guardsValue = v['guardias'];
    if (guardsValue is List) {
      guardiasDisplay = guardsValue.join(', '); // Unir si todavía es lista
    } else {
      guardiasDisplay = guardsValue as String? ?? 'Ninguno';
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
                      "$origen a $destino ($vuelta)", // Título con Origen y Destino
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        tooltip: 'Editar esta vuelta',
                      ),
                    if (isCurrentUser)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade700),
                        onPressed: () => _confirmDelete(docId, destino, vuelta),
                        tooltip: 'Eliminar esta vuelta',
                      ),
                  ],
                ),
              ],
            ),
            Divider(height: 15, color: Colors.grey[300]),

            // Detalles de la Vuelta
            _buildDetailRow(Icons.calendar_today, "Inicio", fechaDisplay),
            _buildDetailRow(Icons.location_city, "Origen",
                origen), // <<< MOSTRANDO EL ORIGEN
            _buildDetailRow(Icons.location_on, "Destino", destino),
            _buildDetailRow(Icons.security, "Guardia(s)", guardiasDisplay),

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

  // === WIDGET PARA EL FORMULARIO DE EDICIÓN (En línea) ===
  Widget _buildEditingForm(String docId) {
    // Usamos los datos temporales del estado _tempEditData para los Dropdowns
    String? currentOrigen =
        _tempEditData['origen'] as String?; // <<< LEYENDO ORIGEN
    String? currentDestino = _tempEditData['destino'] as String?;
    String? currentVuelta = _tempEditData['vuelta'] as String?;
    // Guardias se maneja a través de _guardiaController

    // Crear listas dinámicas que incluyan el valor actual si no está en las opciones estáticas

    // Origenes dinámicos
    List<String> dynamicOrigenes = List.from(_availableOrigenes);
    if (currentOrigen != null && !dynamicOrigenes.contains(currentOrigen)) {
      dynamicOrigenes.insert(0, currentOrigen);
    }

    List<String> dynamicDestinos = List.from(_availableDestinos);
    if (currentDestino != null && !dynamicDestinos.contains(currentDestino)) {
      dynamicDestinos.insert(0, currentDestino);
    }

    List<String> dynamicVueltas = List.from(_availableVueltas);
    if (currentVuelta != null && !dynamicVueltas.contains(currentVuelta)) {
      dynamicVueltas.insert(0, currentVuelta);
    }

    // Aseguramos que el controlador exista (debería existir si _editingDocId no es null)
    if (_guardiaController == null) {
      // Caso de seguridad, aunque _startEditing debería inicializarlo
      _guardiaController = TextEditingController();
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
            Text("Editando Vuelta",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                )),
            Divider(color: Colors.grey[300]),

            // === CAMPO ORIGEN (Dropdown) <<< NUEVO ===
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
                  _tempEditData['origen'] =
                      newValue; // GUARDANDO ORIGEN TEMPORALMENTE
                });
              },
            ),
            SizedBox(height: 12),

            // === CAMPO DESTINO (Dropdown) ===
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

            // === CAMPO TIPO DE VUELTA (Dropdown) ===
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Tipo de Vuelta',
                icon: Icon(Icons.swap_horiz, color: primaryColor),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              value: currentVuelta,
              items: dynamicVueltas.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _tempEditData['vuelta'] = newValue;
                });
              },
            ),
            SizedBox(height: 16),

            // === CAMPO GUARDIA (TextFormField) - USANDO CONTROLLER ===
            TextFormField(
              controller: _guardiaController, // Usa el controlador
              decoration: InputDecoration(
                labelText: 'Guardia Asignado (Nombre completo)',
                hintText: 'Escribe el nombre del guardia',
                icon: Icon(Icons.security, color: primaryColor),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              // El valor se lee al pulsar Guardar Cambios desde el controlador.
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
      appBar: AppBar(
        title: Text("Historial de Vueltas"),
        backgroundColor: primaryColor, // Color primario
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Header del Drawer (Diseño Unificado)
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

            // Opciones de navegación (Diseño Unificado)
            ListTile(
              leading: Icon(Icons.home, color: primaryColor),
              title: Text("Inicio"),
              onTap: goToHome, // Navegación real
            ),
            ListTile(
              leading: Icon(Icons.directions_car, color: primaryColor),
              title: Text("Registrar Vuelta"),
              onTap: goToRegistrarVuelta, // Navegación real
            ),
            ListTile(
              leading: Icon(Icons.history, color: secondaryColor),
              title: Text("Ver historial",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              selected: true,
              selectedTileColor: primaryColor.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context); // Solo cierra el drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt_1, color: primaryColor),
              title: Text("Agregar Guardia"),
              onTap: goToAgregarGuardia, // Navegación real
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
                // Aquí debes manejar la navegación a la pantalla de login
                // (e.g., Navigator.of(context).pushReplacementNamed('/login');)
                print("Sesión cerrada y navegado a login");
              },
            ),
            SizedBox(height: 10),
          ],
        ),
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

            // LISTADO DE VUELTAS
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
                            "No hay vueltas registradas para esta selección.",
                            style: TextStyle(color: Colors.grey.shade600)));

                  final vueltas = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: vueltas.length,
                    itemBuilder: (context, index) {
                      final v = vueltas[index];
                      final docId = v.id;

                      // Decide si mostrar la vista de edición o la de lectura
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
