import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Paquete de conectividad

const String apiKey = "AIzaSyCjdQTIyBvdGiD5N6S8Sl0vgpTzJK2WPj4";

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundImage: AssetImage('assets/LOGO.png'),
              radius: 20,
            ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.25,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: message.isUser ? const Color.fromARGB(255, 47, 89, 82) : const Color.fromARGB(255, 46, 65, 84),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: message.isUser ? const Radius.circular(12) : Radius.zero,
                bottomRight: message.isUser ? Radius.zero : const Radius.circular(12),
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundImage: AssetImage('assets/USER.jpg'),
              radius: 25,
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isConnected = true; // Estado de la conexión
  String _speechText = '';

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _chat = _model.startChat();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    requestMicrophonePermission();
    _checkConnectivity(); // Comprobar conectividad al iniciar
  }

  // Monitorea la conectividad
  Future<void> _checkConnectivity() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = (result == ConnectivityResult.wifi);
    });

    // Escuchar cambios en el estado de la conexión
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = (result == ConnectivityResult.wifi);
      });
    });
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if ((maxScroll - currentScroll) <= 200) {
        _scrollController.jumpTo(maxScroll);
      }
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-EN");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
    });
    try {
      _messages.add(ChatMessage(text: 'escribiendo...', isUser: false));
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text ?? 'No se recibió respuesta';
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(text: text, isUser: false));
      });
      _scrollDown();
      await _speak(text);
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Error: $e', isUser: false));
      });
    } finally {
      _textController.clear();
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          _stopListening();
        }
      },
      onError: (val) => print('Error del reconocimiento de voz: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _speechText = val.recognizedWords;
            _textController.text = _speechText;
          });
        },
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _showMessageOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: _messages[index].text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensaje copiado')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: () {
                setState(() {
                  _messages.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensaje eliminado')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 34, 139, 34), // Color final del degradado
              Color.fromARGB(197, 0, 68, 194), // Color inicial
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text('ChatBot - gvapp'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () => _showMessageOptions(index),
                    child: ChatBubble(message: _messages[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  Expanded(
                    child: TextField(
                      onSubmitted: _isConnected ? _sendChatMessage : null,
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Envia un mensaje...',
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 5, 111, 138),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 46, 211, 54),
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      enabled: _isConnected, // Deshabilita el campo de texto si no hay WiFi
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: _isConnected ? const Color.fromARGB(255, 21, 245, 107) : Colors.grey,
                    iconSize: 35,
                    onPressed: _isConnected ? () => _sendChatMessage(_textController.text) : null, // Deshabilita el botón si no hay WiFi
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
