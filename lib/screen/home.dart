import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para trabajar con JSON

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nombre = ''; // Aquí se almacena el estado del nombre
  String respuestaApi = ''; // Almacena la respuesta de la API
  final TextEditingController _controller =
      TextEditingController(); // Controlador para el TextField

  // Función que hace la solicitud HTTP
  Future<void> enviarDatos(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.103:3000/api/nombres'),
        headers: {"Content-Type": "application/json"},
       // body: jsonEncode({"name": nombre}),
      );

      if (response.statusCode == 201) {
        // Si la solicitud es exitosa, actualizamos el estado con la respuesta
        setState(() {
          respuestaApi = 'Datos enviados correctamente: ${jsonDecode(response.body)['name']}';
        });
      } else {
        // En caso de error en la solicitud
        setState(() {
          respuestaApi = 'Error en la solicitud: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Si hay un error de red o de otro tipo
      setState(() {
        respuestaApi = 'Error de conexión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GvApp'), backgroundColor: Colors.green),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Image.asset('assets/LOGO.png', width: 100, height: 100),
            const SizedBox(height: 100),
            TextField(
              controller: _controller, // Asocia el controlador al TextField
              decoration: const InputDecoration(
                labelText: '\n\n\n\n\n\n escribe tu nombre...\n\n\n\n\n',
              ),
               textAlign: TextAlign.center,
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.green),
              ),
              onPressed: () {
                setState(() {
                  nombre = _controller
                      .text; // Actualiza el estado con el valor del TextField
                });

                // Llama a la función que envía los datos a la API
                enviarDatos(nombre);
              },
              child: const Text('Enviar'),
            ),
            Text('tu: $nombre'), // Muestra el nombre ingresado
            const SizedBox(height: 20), // Espacio entre los elementos
            Text(respuestaApi), // Muestra la respuesta de la API
          ],
        ),
      ),
    );
  }
}
