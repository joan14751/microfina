// lib/services/loan_calculation_service.dart

import '../models/loan_model.dart';
import '../models/quota_model.dart';

class LoanCalculationService {
  
  /// Genera la lista de cuotas basadas en el modelo de préstamo.
  List<QuotaModel> generateQuotas(LoanModel loan, String loanId) {
    List<QuotaModel> quotas = [];
    
    // Usamos el cálculo simple que tenías (solo capital dividido)
    double monthlyPayment = loan.amount / loan.termMonths;
    
    // La fecha de inicio de cálculo de vencimiento
    DateTime startDate = DateTime.now(); 

    for (int i = 1; i <= loan.termMonths; i++) {
      // Cálculo de la fecha de vencimiento (aproximación de 30 días)
      DateTime dueDate = startDate.add(Duration(days: 30 * i));
      
      QuotaModel quota = QuotaModel(
        loanId: loanId,
        quotaNumber: i,
        dueDate: dueDate,
        amountDue: monthlyPayment, 
        amountPaid: 0.0,
        isPaid: false,
      );
      quotas.add(quota);
    }
    return quotas;
  }
}