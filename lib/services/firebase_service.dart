import 'package:auto/models/electric_vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Autenticación
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // CRUD Operaciones
  Future<void> addVehicle(ElectricVehicle vehicle) async {
    try {
      await _firestore.collection('vehicles').add(vehicle.toMap());
    } catch (e) {
      throw Exception('Error al agregar vehículo: $e');
    }
  }

  Stream<List<ElectricVehicle>> getVehicles() {
    return _firestore.collection('vehicles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ElectricVehicle.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateVehicle(ElectricVehicle vehicle) async {
    try {
      await _firestore
          .collection('vehicles')
          .doc(vehicle.id)
          .update(vehicle.toMap());
    } catch (e) {
      throw Exception('Error al actualizar vehículo: $e');
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).delete();
    } catch (e) {
      throw Exception('Error al eliminar vehículo: $e');
    }
  }
}
