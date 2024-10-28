// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/vehicle_list_screen.dart';
import 'screens/add_edit_vehicle_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Vehículos Eléctricos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Personaliza los colores y el tema según tus necesidades
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => VehicleListScreen(),
        '/add-vehicle': (context) => AddEditVehicleScreen(),
        '/edit-vehicle': (context) => AddEditVehicleScreen(),
      },
    );
  }
}