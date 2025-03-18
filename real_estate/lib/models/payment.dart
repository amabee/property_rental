// Payment model
class Payment {
  final String id;
  final DateTime date;
  final String tenantName;
  final String invoiceNumber;
  final double amount;

  Payment({
    required this.id,
    required this.date,
    required this.tenantName,
    required this.invoiceNumber,
    required this.amount,
  });
}
