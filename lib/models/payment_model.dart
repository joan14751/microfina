class PaymentModel {
  final String? id;
  final String quotaId;
  final String loanId;
  final double amount;
  final DateTime paymentDate;
  final String method;

  PaymentModel({
    this.id,
    required this.quotaId,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    required this.method,
  });

  Map<String, dynamic> toMap() {
    return {
      "quotaId": quotaId,
      "loanId": loanId,
      "amount": amount,
      "paymentDate": paymentDate.toIso8601String(),
      "method": method,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      quotaId: data["quotaId"],
      loanId: data["loanId"],
      amount: (data["amount"] as num).toDouble(),
      paymentDate: DateTime.parse(data["paymentDate"]),
      method: data["method"],
    );
  }
}
