class Tenant {
  String id;
  String firstname;
  String middlename;
  String lastname;
  String email;
  String contact;
  String houseID;
  String houseNo;
  String status;
  String dateIn;
  int monthlyRent;
  int payable;
  int paid;
  String lastPayment;
  int outstanding;

  Tenant({
    required this.id,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.email,
    required this.contact,
    required this.houseID,
    required this.houseNo,
    required this.status,
    required this.dateIn,
    required this.monthlyRent,
    required this.payable,
    required this.paid,
    required this.lastPayment,
    required this.outstanding,
  });


  String get name => '$firstname $lastname';
  String get phone => contact;
  String get propertyId => houseID;
  String get propertyName => 'House #$houseNo';
  DateTime get leaseStart => DateTime.tryParse(dateIn) ?? DateTime.now();
  DateTime get leaseEnd => leaseStart.add(Duration(days: 365));
  String get paymentStatus => status;
  bool get depositPaid => paid > 0;
}