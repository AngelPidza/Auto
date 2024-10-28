// lib/screens/add_edit_vehicle_screen.dart
import 'package:auto/models/electric_vehicle.dart';
import 'package:auto/services/firebase_service.dart';
import 'package:flutter/material.dart';

class AddEditVehicleScreen extends StatefulWidget {
  @override
  _AddEditVehicleScreenState createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  late TextEditingController _modelController;
  late TextEditingController _brandController;
  late TextEditingController _batteryCapacityController;
  late TextEditingController _rangeController;
  late TextEditingController _chargeLevelController;

  ElectricVehicle? _vehicle;
  bool get isEditing => _vehicle != null;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController();
    _brandController = TextEditingController();
    _batteryCapacityController = TextEditingController();
    _rangeController = TextEditingController();
    _chargeLevelController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener el vehículo si estamos en modo edición
    final vehicle =
        ModalRoute.of(context)?.settings.arguments as ElectricVehicle?;
    if (vehicle != null && _vehicle == null) {
      _vehicle = vehicle;
      _modelController.text = vehicle.model;
      _brandController.text = vehicle.brand;
      _batteryCapacityController.text = vehicle.batteryCapacity.toString();
      _rangeController.text = vehicle.range.toString();
      _chargeLevelController.text = vehicle.chargeLevel.toString();
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _brandController.dispose();
    _batteryCapacityController.dispose();
    _rangeController.dispose();
    _chargeLevelController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = ElectricVehicle(
      id: isEditing ? _vehicle!.id : null,
      model: _modelController.text,
      brand: _brandController.text,
      batteryCapacity: double.parse(_batteryCapacityController.text),
      range: double.parse(_rangeController.text),
      chargeLevel: int.parse(_chargeLevelController.text),
      lastCharge: DateTime.now(),
    );

    try {
      if (isEditing) {
        await _firebaseService.updateVehicle(vehicle);
      } else {
        await _firebaseService.addVehicle(vehicle);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Vehículo' : 'Agregar Vehículo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(labelText: 'Modelo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el modelo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: 'Marca'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la marca';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _batteryCapacityController,
                decoration: InputDecoration(
                  labelText: 'Capacidad de Batería (kWh)',
                  suffixText: 'kWh',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la capacidad de la batería';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rangeController,
                decoration: InputDecoration(
                  labelText: 'Autonomía (km)',
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la autonomía';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _chargeLevelController,
                decoration: InputDecoration(
                  labelText: 'Nivel de Carga (%)',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nivel de carga';
                  }
                  final number = int.tryParse(value);
                  if (number == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  if (number < 0 || number > 100) {
                    return 'El nivel de carga debe estar entre 0 y 100';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVehicle,
                child: Text(isEditing ? 'Actualizar' : 'Guardar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
