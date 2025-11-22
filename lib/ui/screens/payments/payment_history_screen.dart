// lib/ui/screens/payments/payment_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/payment_model.dart';
import '../../../services/firestore_service.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final String loanId;

  const PaymentHistoryScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Pagos"),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<List<PaymentModel>>(
        stream: firestoreService.getPaymentsByLoanId(loanId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar pagos: ${snapshot.error}"),
            );
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return const Center(
              child: Text(
                "No hay pagos registrados",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final currencyFormatter =
              NumberFormat.currency(locale: 'es_PE', symbol: 'S/. ');

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: payments.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final p = payments[index];
              return ListTile(
                leading: Icon(
                  p.amountPaid() ? Icons.check_circle : Icons.pending,
                  color: p.amountPaid() ? Colors.green : Colors.orange,
                ),
                title: Text("Monto: ${currencyFormatter.format(p.amount)}"),
                subtitle:
                    Text("Fecha: ${DateFormat('dd/MM/yyyy').format(p.paymentDate)}"),
                trailing: Text(p.method),
              );
            },
          );
        },
      ),
    );
  }
}

extension PaymentExt on PaymentModel {
  bool amountPaid() => amount > 0;
}
