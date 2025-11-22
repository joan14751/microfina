// lib/state/loan_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

/// 1️⃣ Provider para FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// 2️⃣ Provider para obtener el UID del usuario autenticado
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );
});

/// 3️⃣ Provider que obtiene todos los préstamos del usuario actual
final loansListProvider = StreamProvider<List<LoanModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    // Devuelve un stream vacío si el usuario no está logueado
    return Stream.value(const []);
  }

  // 🔹 Llama al método correcto de FirestoreService
  return firestoreService.getLoansByUserId(userId);
});
