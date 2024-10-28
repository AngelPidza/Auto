import 'package:auto/models/electric_vehicle.dart';
import 'package:auto/services/firebase_service.dart';
import 'package:flutter/material.dart';

class VehicleListScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Vehículos Eléctricos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-vehicle'),
          ),
        ],
      ),
      body: StreamBuilder<List<ElectricVehicle>>(
        stream: _firebaseService.getVehicles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final vehicles = snapshot.data!;

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return ListTile(
                title: Text('${vehicle.brand} ${vehicle.model}'),
                subtitle: Text(
                  'Autonomía: ${vehicle.range}km | Batería: ${vehicle.chargeLevel}%',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/edit-vehicle',
                        arguments: vehicle,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmar eliminación'),
                            content: Text('¿Desea eliminar este vehículo?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm) {
                          await _firebaseService.deleteVehicle(vehicle.id!);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
