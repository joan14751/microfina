// lib/models/loan_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String? id;
  final String userId;
  final double amount;
  final int termMonths;
  final double interestRate;
  final String status;
  final DateTime requestDate;

  LoanModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.termMonths,
    required this.interestRate,
    this.status = 'Pending',
    required this.requestDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'termMonths': termMonths,
      'interestRate': interestRate,
      'status': status,
      'requestDate': Timestamp.fromDate(requestDate),
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map, String id) {
    return LoanModel(
      id: id,
      userId: map['userId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      termMonths: map['termMonths'] as int,
      interestRate: (map['interestRate'] as num).toDouble(),
      status: map['status'] ?? 'Unknown',
      requestDate: (map['requestDate'] as Timestamp).toDate(),
    );
  }
}
