class Payment {
  Payment({
    required this.id,
    required this.amount,
    required this.dueDate,
    this.paidOn,
    this.notes,
  });

  final String id;
  final double amount;
  final DateTime dueDate;
  DateTime? paidOn;
  final String? notes;

  bool get isPaid => paidOn != null;

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());
}
