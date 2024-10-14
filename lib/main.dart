import 'package:GvApp/screen/bot.dart';
import 'package:flutter/material.dart';
import 'package:GvApp/screen/contacts.dart';
import 'package:GvApp/screen/location_status.dart';
import 'package:GvApp/screen/home.dart';
import 'package:GvApp/screen/scafold.dart';  
import 'package:url_launcher/url_launcher.dart';
import 'package:GvApp/screen/chat.dart';

final Uri _url = Uri.parse('https://github.com/cristianrm13/APP_practica2.git'); 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade900),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // Lista de pantallas
  final List<Widget> _screens = [
    const HomeScreen(),
    const GladBoxHomeScreen(),
    const Products(),
    const LocationStatusScreen(),
    const ContactsScreen(),
    const ChatScreen(),
  ];
  // Función para abrir la URL
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('No se pudo abrir la URL $_url');
    }
  }
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex); // Inicializa el PageController
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 100), // Animación de cambio de página
      curve: Curves.easeInOut,
    );
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
        Positioned(
          top: 25, // posición vertical
          left: 325, // posición horizontal
          child: FloatingActionButton(
            onPressed: _launchUrl,
            tooltip: 'Flutter',
            backgroundColor: const Color.fromARGB(132, 134, 133, 133),
            elevation: 10,
            child: const Icon(Icons.circle_outlined, color: Colors.white),
          ),
        ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Productos'),
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Ubicación'),
        BottomNavigationBarItem(icon: Icon(Icons.contacts_outlined), label: 'Informacion'),
        BottomNavigationBarItem(icon: Icon(Icons.messenger), label: 'ChatBot'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
}
