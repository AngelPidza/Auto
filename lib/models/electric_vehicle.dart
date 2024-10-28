class ElectricVehicle {
  String? id;
  String model;
  String brand;
  double batteryCapacity;
  double range;
  int chargeLevel;
  DateTime lastCharge;

  ElectricVehicle({
    this.id,
    required this.model,
    required this.brand,
    required this.batteryCapacity,
    required this.range,
    required this.chargeLevel,
    required this.lastCharge,
  });

  Map<String, dynamic> toMap() {
    return {
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
      model: map['model'],
      brand: map['brand'],
      batteryCapacity: map['batteryCapacity'],
      range: map['range'],
      chargeLevel: map['chargeLevel'],
      lastCharge: DateTime.parse(map['lastCharge']),
    );
  }
}
