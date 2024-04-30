import 'dart:async';

import 'package:kitchenKeeper/home/create_user.dart';
import 'package:flutter/material.dart';
import 'package:kitchenKeeper/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Función para analizar la temperatura desde la respuesta JSON
double parseTemperature(String responseBody) {
  final parsed = jsonDecode(responseBody);
  final results = parsed['results'];
  final firstResult =
      results[0]; // Obtiene el primer elemento de la lista de resultados
  final value = firstResult[
      'value']; // Obtiene el valor de la clave 'value' del primer resultado
  return value.toDouble(); // Convierte el valor a double
}

// Función asincrónica para obtener la temperatura
Future<double> fetchTemperature() async {
  Uri liga = Uri.parse(
      'https://industrial.api.ubidots.com/api/v1.6/devices/kitchenkeeper/fire-detector/values/?token=BBUS-VuJyKs1WKrWxIwmdY0FbSiE6cSc5Ys');
  final response = await http.get(liga);

  if (response.statusCode == 200) {
    // Si la respuesta es exitosa, parsea la respuesta JSON y devuelve la temperatura
    return parseTemperature(response.body);
  } else {
    // Si la respuesta no es exitosa, lanza una excepción
    throw Exception('Failed to fetch temperature');
  }
}

Future<double> fetchGas() async {
  Uri liga = Uri.parse(
      'https://industrial.api.ubidots.com/api/v1.6/devices/kitchenkeeper/air-quality/values/?token=BBUS-VuJyKs1WKrWxIwmdY0FbSiE6cSc5Ys');
  final response = await http.get(liga);

  if (response.statusCode == 200) {
    // Si la respuesta es exitosa, parsea la respuesta JSON y devuelve la temperatura
    return parseTemperature(response.body);
  } else {
    // Si la respuesta no es exitosa, lanza una excepción
    throw Exception('Failed to fetch temperature');
  }
}

Future<int> fetchAndSumGasValues() async {
  Uri url = Uri.parse(
      'https://industrial.api.ubidots.com/api/v1.6/devices/kitchenkeeper/air-quality/values/?token=BBUS-VuJyKs1WKrWxIwmdY0FbSiE6cSc5Ys');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['results'];
    int sum = 0;
    for (var item in data) {
      if (item['value'] == 1) {
        sum++;
      }
    }
    return sum;
  } else {
    throw Exception('Failed to fetch gas values');
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double temperature = 0.0;
  late double gas = 0.0;
  late int fugasDeGas = 0;

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Inicializar el plugin de notificaciones
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Inicia el temporizador al cargar la página
    Timer.periodic(Duration(seconds: 1), (timer) {
      fetchTemperature().then((value) {
        setState(() {
          temperature = value;
        });
      }).catchError((error) {
        print(error);
      });
      fetchGas().then((value) {
        setState(() {
          gas = value;

          // Generar notificación si el valor de gas es 1
          if (gas == 1) {
            _showGasAlertNotification();
          }
        });
      }).catchError((error) {
        print(error);
      });
      fetchAndSumGasValues().then((value) {
        setState(() {
          fugasDeGas = value;
          print(value);
        });
      }).catchError((error) {
        print(error);
      });
    });
  }

  // Método para cerrar sesión
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Después de cerrar sesión, navega de regreso a la página de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(), // Página de inicio
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  // Método para mostrar la notificación de alerta de gas
  Future<void> _showGasAlertNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'gas_alert_channel',
      'Gas Alert',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableLights: true,
      color: Colors.red,
      ledColor: Colors.red,
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Alerta de Gas',
      'Se ha detectado una fuga de gas',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isAllowedUser = currentUser != null &&
        currentUser.uid == 'UmSa5sDykGMhQAztSpgzb4zZ7JW2';

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          // Agrega un botón de cierre de sesión en la barra de aplicaciones
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 150,
                  height: 150,
                  color: gas == 1 ? Colors.red : Colors.green,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Detector de Gas:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          gas == 1 ? "Hay una fuga de gas" : "No hay fuga",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          gas == 1 ? Icons.dangerous : Icons.check,
                          color: Colors.white,
                          size: 30,
                        )
                      ]),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 150,
                  height: 150,
                  color: temperature == 1 ? Colors.red : Colors.green,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Detector de Fuego:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          temperature == 1
                              ? "La estufa esta encendida"
                              : "Estufa apagada",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          temperature == 1 ? Icons.dangerous : Icons.check,
                          color: Colors.white,
                          size: 30,
                        )
                      ]),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 320,
              height: 150,
              color: const Color.fromARGB(255, 190, 181, 154),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Total de fugas en el mes",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      fugasDeGas == 0
                          ? fugasDeGas.toString()
                          : fugasDeGas.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
            ),
          ),
          //Insertar botón para agregar usuarios solo si es el usuario permitido
          if (isAllowedUser)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateUserPage()),
                );
              },
              child: Text('Crear Usuario'),
            ),
        ],
      ),
    );
  }
}
