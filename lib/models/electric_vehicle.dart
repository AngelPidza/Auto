class ElectricVehicle {
  String? id;
  String userId; // Añadimos el ID del usuario
  String model;
  String brand;
  double batteryCapacity;
  double range;
  int chargeLevel;
  DateTime lastCharge;

  ElectricVehicle({
    this.id,
    required this.userId,
    required this.model,
    required this.brand,
    required this.batteryCapacity,
    required this.range,
    required this.chargeLevel,
    required this.lastCharge,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'model': model,
      'brand': brand,
      'batteryCapacity': batteryCapacity,
      'range': range,
      'chargeLevel': chargeLevel,
      'lastCharge': lastCharge.toIso8601String(),
    };
  }

  factory ElectricVehicle.fromMap(Map<String, dynamic> map, String id) {
    return ElectricVehicle(
      id: id,
      userId: map['userId'] ?? '',
      model: map['model'] ?? '',
      brand: map['brand'] ?? '',
      batteryCapacity: (map['batteryCapacity'] ?? 0).toDouble(),
      range: (map['range'] ?? 0).toDouble(),
      chargeLevel: map['chargeLevel'] ?? 0,
      lastCharge:
          DateTime.parse(map['lastCharge'] ?? DateTime.now().toIso8601String()),
    );
  }
}
