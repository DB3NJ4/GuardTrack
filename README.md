# 🛡️ GuardTrack - Sistema de Gestión de Seguridad

## 📋 Descripción  
**GuardTrack** es una aplicación móvil desarrollada en **Flutter** por **SmartSolutions**, diseñada para optimizar la **gestión de rondas de seguridad y personal de vigilancia**.  
Pensada para **empresas de seguridad privada** que gestionan múltiples clientes, como **Concha y Toro** y **Sodexo**, ofrece control, trazabilidad y eficiencia en cada operación.

---

## 🚀 Características Principales

### 🔄 Gestión de Vueltas  
- Registro y seguimiento en tiempo real de rondas por empresa.  
- Visualización de recorridos activos y completados.  
- Historial detallado con filtros por fecha.  
- Funciones de edición y eliminación de registros.

### 👥 Gestión de Personal  
- Registro de **guardias (Concha y Toro)** y **trabajadores (Sodexo)**.  
- Datos completos: nombre, RUT, teléfono y estado.  
- CRUD completo para la administración del personal.

### 🎨 Interfaz Moderna  
- Diseño **responsive** basado en **Material Design**.  
- **Dashboard dinámico** con estadísticas en tiempo real.  
- Navegación fluida mediante **Custom Drawer** personalizable.  
- Experiencia de usuario optimizada para móviles y tablets.

---

## 🏗️ Estructura del Proyecto
lib/
├── components/
│   └── custom_drawer.dart      # Drawer reutilizable
├── home_page.dart              # Dashboard principal
├── saveround_page.dart         # Vuelta Concha y Toro
├── saveguard_page.dart         # Gestión de Guardias
├── historial_page.dart         # Historial Concha y Toro
├── saveroundsodexo_page.dart   # Vuelta Sodexo
├── savesodexo_page.dart        # Gestión de Trabajadores Sodexo
├── historialsodexo_page.dart   # Historial Sodexo
└── configuration.dart          # Configuración general


---

## 🛠️ Tecnologías Utilizadas
- 🧱 **Flutter** — Framework principal de desarrollo  
- 🔐 **Firebase Authentication** — Gestión de usuarios y acceso seguro  
- ☁️ **Cloud Firestore** — Base de datos en tiempo real  
- 🎨 **Material Design** — Sistema de diseño para una UI moderna y consistente  

---

## 📊 Módulos Principales

### 🏠 Dashboard (HomePage)
- Estadísticas en tiempo real  
- Rondas realizadas en el día  
- Total de guardias y trabajadores  
- Accesos rápidos a los módulos principales  

### 🍷 Concha y Toro
- Registro de rondas de seguridad  
- Gestión de guardias  
- Historial completo de operaciones  

### 🏢 Sodexo
- Registro de rondas Sodexo  
- Administración de trabajadores  
- Consulta de historial por fechas  

---

## 🔧 Instalación

### Prerrequisitos
- **Flutter SDK** 3.0 o superior  
- **Dart** 2.17 o superior  
- **Cuenta de Firebase** configurada  

### Instalación
Clona el repositorio y ejecuta:
```bash
git clone https://github.com/tuusuario/guardtrack.git
cd guardtrack
flutter pub get
flutter run
```
---

📄 Licencia

Este proyecto está distribuido bajo la MIT License.
Consulta el archivo LICENSE.md
 para más información.

 ---
 
💼 Desarrollado por:
SmartSolutions — Innovación y tecnología al servicio de la seguridad.
