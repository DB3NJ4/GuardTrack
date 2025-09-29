import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // === LÓGICA DE FIREBASE Y ESTADO ===
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool loading = false;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    // Redirige si el usuario ya está logueado
    if (_auth.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Asegúrate de que '/home' esté definido en tus rutas de MaterialApp
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Si el inicio de sesión fue exitoso
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta';
      } else {
        message = e.message ?? 'Error al iniciar sesión';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // === DISEÑO (BUILD) ===
  @override
  Widget build(BuildContext context) {
    // Definimos los colores del degradado (Celeste a Azul)
    const Color topColor = Color(0xFF00C6FF); // Celeste brillante
    const Color bottomColor = Color(0xFF0072FF); // Azul más oscuro

    return Scaffold(
      // Scaffold transparente para mostrar el degradado de fondo
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          // 1. Fondo Degradado (Cubre toda la pantalla)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, bottomColor],
              ),
            ),
          ),

          // 2. Contenido de la Pantalla (Centrado y con Scroll)
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    // Espacio Superior
                    SizedBox(height: 50),

                    // Icono de Check y Texto WELCOME!!
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 80,
                    ),
                    SizedBox(height: 10),

                    Text(
                      "WELCOME!!",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 60),

                    // 3. Contenedor Blanco del Formulario (White Card)
                    Container(
                      // ANCHO: 85% del ancho de la pantalla (Menos ancho)
                      width: MediaQuery.of(context).size.width * 0.9,

                      // ALTURA: Se ajusta al contenido (Menos largo/compacto)
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 50),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // Borde redondo completo para efecto flotante
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Campo de Email
                          _buildTextField(
                            controller: emailController,
                            hintText: "Username / Email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 20),

                          // Campo de Contraseña
                          _buildPasswordTextField(bottomColor),
                          SizedBox(height: 10),

                          // Texto de Contraseña Olvidada
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Lógica para recuperar contraseña
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Botón de Login
                          loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          bottomColor)))
                              : ElevatedButton(
                                  onPressed: login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        bottomColor, // Color del botón
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 5,
                                    shadowColor: bottomColor.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                          SizedBox(height: 20),

                          // Enlace de Registro
                          TextButton(
                            onPressed: () {
                              // Lógica para navegar a la página de registro
                            },
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have a Account? ",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Register",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: bottomColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50), // Espacio inferior
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGETS AUXILIARES ===

  // Helper para crear campos de texto estándar
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none, // Ocultar el borde
        ),
      ),
    );
  }

  // Helper para el campo de contraseña con el icono de visibilidad
  Widget _buildPasswordTextField(Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextField(
        controller: passwordController,
        obscureText: hidePassword,
        decoration: InputDecoration(
          hintText: "Password",
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          prefixIcon: Icon(Icons.vpn_key_outlined, color: Colors.grey[600]),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              hidePassword ? Icons.visibility_off : Icons.visibility,
              color: accentColor, // Usa el color azul del tema
            ),
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
          ),
        ),
      ),
    );
  }
}
