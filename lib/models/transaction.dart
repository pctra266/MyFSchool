class Transaction {
  final int id;
  final int studentId;
  final String title;
  final double amount;
  final String transactionType;
  final String status;
  final DateTime? transactionDate;

  Transaction({
    required this.id,
    required this.studentId,
    required this.title,
    required this.amount,
    required this.transactionType,
    required this.status,
    this.transactionDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      transactionType: json['transactionType'] ?? '',
      status: json['status'] ?? '',
      transactionDate: json['transactionDate'] != null
          ? DateTime.tryParse(json['transactionDate'])
          : null,
    );
  }
}
