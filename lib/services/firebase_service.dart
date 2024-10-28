import 'package:auto/models/electric_vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
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

  // Cierre de sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // CRUD Operaciones
  Future<void> addVehicle(ElectricVehicle vehicle) async {
    if (currentUser == null) throw Exception('Usuario no autenticado');

    try {
      // Aseguramos que el userId sea el del usuario actual
      vehicle.userId = currentUser!.uid;
      await _firestore.collection('vehicles').add(vehicle.toMap());
    } catch (e) {
      throw Exception('Error al agregar vehículo: $e');
    }
  }

  Stream<List<ElectricVehicle>> getVehicles() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('vehicles')
        .where('userId', isEqualTo: currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ElectricVehicle.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateVehicle(ElectricVehicle vehicle) async {
    if (currentUser == null) throw Exception('Usuario no autenticado');

    try {
      // Verificar que el vehículo pertenece al usuario actual
      final vehicleDoc =
          await _firestore.collection('vehicles').doc(vehicle.id).get();
      if (vehicleDoc.data()?['userId'] != currentUser!.uid) {
        throw Exception('No tienes permiso para modificar este vehículo');
      }

      await _firestore
          .collection('vehicles')
          .doc(vehicle.id)
          .update(vehicle.toMap());
    } catch (e) {
      throw Exception('Error al actualizar vehículo: $e');
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    if (currentUser == null) throw Exception('Usuario no autenticado');

    try {
      // Verificar que el vehículo pertenece al usuario actual
      final vehicleDoc =
          await _firestore.collection('vehicles').doc(vehicleId).get();
      if (vehicleDoc.data()?['userId'] != currentUser!.uid) {
        throw Exception('No tienes permiso para eliminar este vehículo');
      }

      await _firestore.collection('vehicles').doc(vehicleId).delete();
    } catch (e) {
      throw Exception('Error al eliminar vehículo: $e');
    }
  }
}
