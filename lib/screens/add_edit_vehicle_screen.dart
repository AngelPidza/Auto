import 'package:auto/models/electric_vehicle.dart';
import 'package:auto/services/firebase_service.dart';
import 'package:flutter/material.dart';

class AddEditVehicleScreen extends StatefulWidget {
  const AddEditVehicleScreen({super.key});
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
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = ElectricVehicle(
        id: isEditing ? _vehicle!.id : null,
        userId: _firebaseService.currentUser!.uid,
        model: _modelController.text,
        brand: _brandController.text,
        batteryCapacity: double.parse(_batteryCapacityController.text),
        range: double.parse(_rangeController.text),
        chargeLevel: int.parse(_chargeLevelController.text),
        lastCharge: DateTime.now(),
      );

      if (isEditing) {
        await _firebaseService.updateVehicle(vehicle);
      } else {
        await _firebaseService.addVehicle(vehicle);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          suffixText: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade500, Colors.green.shade100],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(
                isEditing ? 'Editar Vehículo' : 'Agregar Vehículo',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInputField(
                            controller: _modelController,
                            label: 'Modelo',
                            icon: Icons.directions_car,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el modelo';
                              }
                              return null;
                            },
                          ),
                          _buildInputField(
                            controller: _brandController,
                            label: 'Marca',
                            icon: Icons.branding_watermark,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese la marca';
                              }
                              return null;
                            },
                          ),
                          _buildInputField(
                            controller: _batteryCapacityController,
                            label: 'Capacidad de Batería',
                            icon: Icons.battery_full,
                            suffix: 'kWh',
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
                          _buildInputField(
                            controller: _rangeController,
                            label: 'Autonomía',
                            icon: Icons.speed,
                            suffix: 'km',
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
                          _buildInputField(
                            controller: _chargeLevelController,
                            label: 'Nivel de Carga',
                            icon: Icons.battery_charging_full,
                            suffix: '%',
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
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveVehicle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isEditing
                                          ? 'Actualizar Vehículo'
                                          : 'Guardar Vehículo',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
