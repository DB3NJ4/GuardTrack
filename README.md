# 🛡️ Guardias App - Flutter

Aplicación móvil desarrollada en **Flutter** para la gestión de **guardias y vueltas**. Permite registrar, visualizar y administrar turnos de guardias con filtros por fecha, opciones de vuelta y administración de guardias.

---

## ✨ Características

- 📝 **Registrar nuevas vueltas**:
  - 📅 Fecha de inicio
  - ⏰ Vuelta (08:00, 16:00, 18:00, 00:00)
  - 🏭 Destino (Bodega o CII)
  - 👮 Selección de **guardias**
  - 🚗 Chofer (usuario actual)

- 📊 **Ver historial de vueltas**:
  - Filtro por fecha
  - Listado de guardias en cada vuelta
  - Orden descendente por fecha

- 🛡️ **Administrar guardias**:
  - ➕ Crear nuevos guardias
  - ✏️ Editar guardias existentes
  - ❌ Eliminar guardias
  - 📋 Listado completo de guardias registrados

- 🔗 **Integración con Firebase**:
  - Firestore para almacenamiento de datos
  - Firebase Auth para autenticación de usuarios

---

## 📂 Estructura de Firestore

### Colección `guardias`
Cada documento representa un guardia con los campos:
- `nombre` : `String`  
- `telefono` : `String`  
- `timestamp` : `Timestamp`  

### Colección `vueltas`
Cada documento representa una vuelta con los campos:
- `chofer` : `String` (UID del usuario)  
- `origen` : `String` (por defecto: Talca)  
- `destino` : `String`  
- `fechaInicio` : `DateTime`  
- `vuelta` : `String`  
- `guardias` : `Array<String>`  
- `timestamp` : `Timestamp`  

---
