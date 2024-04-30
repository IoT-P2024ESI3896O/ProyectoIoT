import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/bloc/auth_bloc.dart';
import '../home/home_page.dart'; // Importa la página de inicio
import '../home/devices_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Método para mostrar la Snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Image.asset(
              "assets/icons/logo.png",
              height: 120,
            ),
            Image.asset(
              "assets/icons/logojust.png",
              height: 120,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            SizedBox(height: 20),
            MaterialButton(
              child: Text("Iniciar sesión"),
              color: Colors.blue,
              onPressed: () async {
                try {
                  UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  // Después del inicio de sesión exitoso, navega a la página de inicio
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomComponentScreen(), // Página de inicio
                    ),
                  );
                } catch (e) {
                  // Maneja errores de inicio de sesión aquí
                  print(e);
                  // Muestra la Snackbar si hay un error de inicio de sesión
                  _showSnackBar(
                      'Error de inicio de sesión. Verifica tu correo electrónico y contraseña.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
