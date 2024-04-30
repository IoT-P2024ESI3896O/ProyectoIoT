import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Importa el paquete de la cámara
import 'home_page.dart'; // Asegúrate de importar correctamente el archivo home_page.dart

class CustomComponent extends StatelessWidget {
  final String componentNumber;
  final String imageAddress;

  CustomComponent(this.componentNumber, this.imageAddress);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              image: AssetImage(imageAddress),
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Casa $componentNumber",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child:
                    Container(), // Agrega un contenedor vacío para ocupar el espacio restante
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomComponentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locaciones'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              _openCamera(context); // Llama a la función para abrir la cámara
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CustomComponent("Del campo", "assets/icons/fondoComponente.png"),
          CustomComponent("Ciudad", "assets/icons/gdl.png"),
          CustomComponent("Máma", "assets/icons/mama.png"),
        ],
      ),
    );
  }

  // Función para abrir la cámara
  void _openCamera(BuildContext context) async {
    // Obtén la lista de cámaras disponibles
    final cameras = await availableCameras();
    // Abre la página de la cámara
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
            cameras), // Pasa la lista de cámaras a la página de la cámara
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraPage(this.cameras);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    // Selecciona la primera cámara de la lista
    _controller = CameraController(
      widget.cameras[0], // Utiliza la primera cámara de la lista
      ResolutionPreset.medium,
    );
    // Inicializa el controlador de la cámara
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera los recursos de la cámara
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child:
            CameraPreview(_controller), // Muestra la vista previa de la cámara
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CustomComponentScreen(),
  ));
}
