import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/models/payment.dart';
import 'package:real_estate/pages/staff_pages/dashboard.dart';
import 'package:real_estate/pages/staff_pages/house_types.dart';
import 'package:real_estate/pages/staff_pages/houses.dart';
import 'package:real_estate/pages/staff_pages/reports.dart';
import 'package:real_estate/pages/staff_pages/tenants.dart';
import 'package:real_estate/pages/login_page.dart';

class StaffPaymentsScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const StaffPaymentsScreen({
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _StaffPaymentsScreenState createState() => _StaffPaymentsScreenState();
}

class _StaffPaymentsScreenState extends State<StaffPaymentsScreen> {
  // Sample payment data
  final List<Payment> _payments = [
    Payment(
      id: '1',
      date: DateTime(2025, 3, 15),
      tenantName: 'Maria Garcia',
      invoiceNumber: 'INV-2025-001',
      amount: 12500.00,
    ),
    Payment(
      id: '2',
      date: DateTime(2025, 3, 10),
      tenantName: 'James Wilson',
      invoiceNumber: 'INV-2025-002',
      amount: 8500.00,
    ),
    Payment(
      id: '3',
      date: DateTime(2025, 3, 5),
      tenantName: 'Sarah Johnson',
      invoiceNumber: 'INV-2025-003',
      amount: 15000.00,
    ),
    Payment(
      id: '4',
      date: DateTime(2025, 2, 28),
      tenantName: 'Robert Lee',
      invoiceNumber: 'INV-2025-004',
      amount: 9200.00,
    ),
    Payment(
      id: '5',
      date: DateTime(2025, 2, 20),
      tenantName: 'Emily Wong',
      invoiceNumber: 'INV-2025-005',
      amount: 10800.00,
    ),
  ];

  String _searchQuery = '';
  List<Payment> _filteredPayments = [];

  @override
  void initState() {
    super.initState();
    _filteredPayments = List.from(_payments);
  }

  void _filterPayments(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPayments = List.from(_payments);
      } else {
        _filteredPayments =
            _payments
                .where(
                  (payment) =>
                      payment.tenantName.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      payment.invoiceNumber.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  void _showPaymentOptions(BuildContext context, Payment payment) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.visibility,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showPaymentDetails(context, payment);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.amber),
                title: Text('Edit Payment'),
                onTap: () {
                  Navigator.pop(context);
                  _editPayment(payment);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Payment'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, payment);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentDetails(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Date',
                DateFormat('MMM dd, yyyy').format(payment.date),
              ),
              _detailRow('Tenant', payment.tenantName),
              _detailRow('Invoice', payment.invoiceNumber),
              _detailRow('Amount', '₱${payment.amount.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label + ':',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _editPayment(Payment payment) {
    // Here you would navigate to an edit form or show a modal
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit payment: ${payment.invoiceNumber}')),
    );
  }

  void _confirmDelete(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete payment ${payment.invoiceNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _payments.removeWhere((item) => item.id == payment.id);
                  _filteredPayments = List.from(_payments);
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Payment deleted')));
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterPayments,
              decoration: InputDecoration(
                hintText: 'Search by tenant or invoice',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _filteredPayments.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No payments found',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = _filteredPayments[index];
                        return _buildPaymentCard(payment);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Add new payment')));
        },
        child: Icon(Icons.add),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPaymentOptions(context, payment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      payment.tenantName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₱${payment.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(payment.invoiceNumber),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(DateFormat('MMM dd, yyyy').format(payment.date)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.amber),
                    onPressed: () => _editPayment(payment),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.all(8),
                    iconSize: 20,
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, payment),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.all(8),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Staff Member',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'staff@example.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => StaffDashboardScreen(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('House Types'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => StaffHouseTypesScreen(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Houses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => StaffHousesScreen(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Tenants'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => StaffTenantScreen(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Payments'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.data_exploration_rounded),
            title: Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => StaffReportsScreen(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => LoginScreen(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
