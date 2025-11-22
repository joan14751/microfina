// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';
import '../models/quota_model.dart';
import '../models/payment_model.dart';
// ⬅️ Debes crear este archivo en lib/services/
import 'loan_calculation_service.dart'; 

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ⬅️ Instancia para separar la lógica de negocio (cálculo de cuotas)
  final LoanCalculationService _calcService = LoanCalculationService(); 

  /// Registrar un nuevo préstamo y generar cuotas
  Future<void> requestNewLoan(LoanModel loan, String userId) async {
    if (userId.isEmpty) throw Exception("Usuario no autenticado");

    try {
      // ⭐ OPTIMIZACIÓN 1: Usar Lote de Escrituras (Write Batch) para atomicidad.
      WriteBatch batch = _db.batch();

      // Referencia del nuevo préstamo (generar ID antes de guardar)
      DocumentReference loanRef = _db.collection('loans').doc();
      final loanId = loanRef.id;

      // 1️⃣ Guardar el préstamo con su ID generado
      batch.set(loanRef, {
        ...loan.toMap(),
        'id': loanId, 
        'userId': userId,
      });

      // 2️⃣ Generar cuotas usando el servicio de cálculo (Lógica extraída)
      List<QuotaModel> quotas = _calcService.generateQuotas(loan, loanId);

      // 3️⃣ Escribir todas las cuotas en el mismo lote
      for (QuotaModel quota in quotas) {
        DocumentReference quotaRef = _db.collection('quotas').doc();
        batch.set(quotaRef, {
          ...quota.toMap(),
          'id': quotaRef.id, // Asegurar que el ID de la cuota se guarda
        });
      }

      // 4️⃣ Ejecutar el lote (si falla una, falla toda la operación)
      await batch.commit();

    } catch (e) {
      print("ERROR AL REGISTRAR PRÉSTAMO: $e");
      rethrow;
    }
  }

  /// Obtener préstamos de un usuario
  Stream<List<LoanModel>> getLoansByUserId(String userId) {
    return _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Obtener cuotas de un préstamo
  Stream<List<QuotaModel>> getQuotasByLoanId(String loanId) {
    // Esta consulta requiere el índice compuesto (loanId, quotaNumber) que creaste.
    return _db
        .collection('quotas')
        .where('loanId', isEqualTo: loanId)
        .orderBy('quotaNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuotaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Registrar pago de cuota
  Future<void> registerPayment({
    required QuotaModel quota,
    required double paymentAmount,
    required String paymentMethod,
  }) async {
    final newAmountPaid = quota.amountPaid + paymentAmount;
    final isFullyPaid = newAmountPaid >= quota.amountDue;

    // 1️⃣ Crear el objeto pago
    PaymentModel newPayment = PaymentModel(
      quotaId: quota.id!,
      loanId: quota.loanId,
      amount: paymentAmount,
      paymentDate: DateTime.now(),
      method: paymentMethod,
    );

    // ⭐ OPTIMIZACIÓN 2: Usar Lote de Escrituras para atomicidad (Pago y Actualización de Cuota)
    WriteBatch batch = _db.batch();

    // 2️⃣ Referencia y escritura del Pago
    DocumentReference paymentRef = _db.collection('payments').doc();
    batch.set(paymentRef, {
      ...newPayment.toMap(),
      'id': paymentRef.id,
    });

    // 3️⃣ Actualizar cuota
    batch.update(_db.collection('quotas').doc(quota.id), {
      'amountPaid': newAmountPaid,
      'isPaid': isFullyPaid,
    });
    
    // 4️⃣ Ejecutar lote
    await batch.commit();
  }

  /// Obtener pagos de un préstamo
  Stream<List<PaymentModel>> getPaymentsByLoanId(String loanId) {
    // ⭐ OPTIMIZACIÓN 3: Filtrar por loanId en el servidor (Firestore) en lugar del cliente.
    return _db
        .collection('payments')
        .where('loanId', isEqualTo: loanId) // Filtra en el servidor
        .orderBy('paymentDate', descending: true) // Ordena por fecha (puede requerir un índice compuesto: loanId ASC, paymentDate DESC)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}