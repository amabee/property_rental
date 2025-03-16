class Tenant {
  String id;
  String name;
  String email;
  String phone;
  String propertyId;
  String propertyName;
  DateTime leaseStart;
  DateTime leaseEnd;
  double monthlyRent;
  bool depositPaid;
  String paymentStatus;

  Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.propertyId,
    required this.propertyName,
    required this.leaseStart,
    required this.leaseEnd,
    required this.monthlyRent,
    required this.depositPaid,
    required this.paymentStatus,
  });
}
