import 'package:cloud_firestore/cloud_firestore.dart';

class QuotaModel {
  final String? id;
  final String loanId;
  final int quotaNumber;
  final DateTime dueDate;
  final double amountDue;
  final double amountPaid;
  final bool isPaid;

  QuotaModel({
    this.id,
    required this.loanId,
    required this.quotaNumber,
    required this.dueDate,
    required this.amountDue,
    required this.amountPaid,
    required this.isPaid,
  });

  Map<String, dynamic> toMap() {
    return {
      "loanId": loanId,
      "quotaNumber": quotaNumber,
      "dueDate": Timestamp.fromDate(dueDate),
      "amountDue": amountDue,
      "amountPaid": amountPaid,
      "isPaid": isPaid,
    };
  }

  factory QuotaModel.fromMap(Map<String, dynamic> map, String id) {
    return QuotaModel(
      id: id,
      loanId: map["loanId"],
      quotaNumber: map["quotaNumber"],
      dueDate: (map["dueDate"] as Timestamp).toDate(),
      amountDue: (map["amountDue"] as num).toDouble(),
      amountPaid: (map["amountPaid"] as num).toDouble(),
      isPaid: map["isPaid"],
    );
  }
}
