// lib/ui/screens/payments/payment_screen.dart

import 'package:flutter/material.dart';
import '../../../models/quota_model.dart';
import '../../../services/firestore_service.dart';

class PaymentScreen extends StatefulWidget {
  final QuotaModel quota;

  const PaymentScreen({super.key, required this.quota});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  String _paymentMethod = 'Transferencia Bancaria';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador con el saldo pendiente
    _amountController = TextEditingController(
      text: (widget.quota.amountDue - widget.quota.amountPaid).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final double paymentAmount = double.tryParse(_amountController.text) ?? 0.0;

      try {
        await _firestoreService.registerPayment(
          quota: widget.quota,
          paymentAmount: paymentAmount,
          paymentMethod: _paymentMethod,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pago registrado con éxito.')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al procesar el pago: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quota = widget.quota;

    return Scaffold(
      appBar: AppBar(title: Text('Pagar Cuota #${quota.quotaNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Resumen de la cuota
              Card(
                elevation: 3,
                child: ListTile(
                  title: Text('Monto Total a Pagar: \$${quota.amountDue.toStringAsFixed(2)}'),
                  subtitle: Text('Pagado hasta ahora: \$${quota.amountPaid.toStringAsFixed(2)}'),
                  trailing: Text(
                    'Pendiente: \$${(quota.amountDue - quota.amountPaid).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Campo de monto a pagar
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto del Pago',
                  prefixText: '\$',
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Ingrese un monto válido.';
                  }
                  if (amount > (quota.amountDue - quota.amountPaid) && !quota.isPaid) {
                    return 'El monto excede el saldo pendiente de esta cuota.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Selector de método de pago
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Método de Pago'),
                items: <String>[
                  'Transferencia Bancaria',
                  'Efectivo',
                  'Tarjeta de Débito'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentMethod = newValue!;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Botón de confirmar pago
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Confirmar Pago',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
