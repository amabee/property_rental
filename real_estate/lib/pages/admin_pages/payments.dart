import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/data/queries/payments.dart';
import 'package:real_estate/data/queries/tenants.dart';
import 'package:real_estate/models/payment.dart';
import 'package:real_estate/models/tenant.dart';
import 'package:real_estate/pages/admin_pages/dashboard.dart';
import 'package:real_estate/pages/admin_pages/house_types.dart';
import 'package:real_estate/pages/admin_pages/houses.dart';
import 'package:real_estate/pages/admin_pages/reports.dart';
import 'package:real_estate/pages/admin_pages/tenants.dart';
import 'package:real_estate/pages/admin_pages/users.dart';
import 'package:real_estate/pages/login_page.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentsScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const PaymentsScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  List<dynamic> _tenants = [];
  bool _isLoadingTenants = false;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    setState(() {
      _isLoadingTenants = true;
    });

    try {
      final tenantsData = await getTenants();

      if (tenantsData != null) {
        setState(() {
          _tenants = tenantsData;
          _isLoadingTenants = false;
        });
      } else {
        setState(() {
          _isLoadingTenants = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load tenants')));
      }
    } catch (e) {
      setState(() {
        _isLoadingTenants = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading tenants: $e')));
    }
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final paymentsData = await getPayments();

      if (paymentsData != null) {
        setState(() {
          _payments =
              paymentsData
                  .map(
                    (data) => Payment(
                      id: data['payment_id'].toString(),
                      date: DateTime.parse(data['date_created']),
                      tenantName:
                          data['firstname'] +
                          ' ' +
                          data['middlename'] +
                          ' ' +
                          data['lastname'],
                      invoiceNumber: data['invoice'],
                      amount: data['amount'],
                    ),
                  )
                  .toList();
          _filteredPayments = List.from(_payments);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Unable to load payments';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading payments: $e';
        _isLoading = false;
      });
    }
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

  void _showAddPaymentModal() {
    String? selectedTenantId;
    final amountController = TextEditingController();
    final invoiceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add New Payment',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Tenant Dropdown
                      _isLoadingTenants
                          ? Center(child: CircularProgressIndicator())
                          : _tenants.isEmpty
                          ? OutlinedButton(
                            onPressed: () async {
                              await _fetchTenants();
                              setModalState(() {});
                            },
                            child: Text('Load Tenants'),
                          )
                          : DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Tenant',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            value: selectedTenantId,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a tenant';
                              }
                              return null;
                            },
                            items:
                                _tenants.map((tenant) {
                                  String fullName =
                                      tenant['firstname'] +
                                      ' ' +
                                      tenant['middlename'] +
                                      ' ' +
                                      tenant['lastname'];

                                  return DropdownMenuItem<String>(
                                    value: tenant['id'].toString(),
                                    child: Text(
                                      fullName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setModalState(() {
                                selectedTenantId = newValue;
                              });
                            },
                          ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: invoiceController,
                        decoration: InputDecoration(
                          labelText: 'Invoice Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an invoice number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount (₱)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Amount must be greater than zero';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () async {
                          await addPayment(
                            context,
                            selectedTenantId!,
                            amountController.text,
                            invoiceController.text,
                          );
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                          }
                          _fetchPayments();
                        },
                        child: Text('Submit Payment'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
    String? selectedTenantId;
    final amountController = TextEditingController(
      text: payment.amount.toString(),
    );
    final invoiceController = TextEditingController(
      text: payment.invoiceNumber,
    );
    final formKey = GlobalKey<FormState>();

    // Find the tenant ID based on the tenant name
    if (_tenants.isNotEmpty) {
      for (var tenant in _tenants) {
        String fullName =
            tenant['firstname'] +
            ' ' +
            tenant['middlename'] +
            ' ' +
            tenant['lastname'];
        if (fullName == payment.tenantName) {
          selectedTenantId = tenant['id'].toString();
          break;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Payment',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Tenant Dropdown
                      _isLoadingTenants
                          ? Center(child: CircularProgressIndicator())
                          : _tenants.isEmpty
                          ? OutlinedButton(
                            onPressed: () async {
                              await _fetchTenants();
                              setModalState(() {});
                            },
                            child: Text('Load Tenants'),
                          )
                          : DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Tenant',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            value: selectedTenantId,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a tenant';
                              }
                              return null;
                            },
                            items:
                                _tenants.map((tenant) {
                                  String fullName =
                                      tenant['firstname'] +
                                      ' ' +
                                      tenant['middlename'] +
                                      ' ' +
                                      tenant['lastname'];

                                  return DropdownMenuItem<String>(
                                    value: tenant['id'].toString(),
                                    child: Text(
                                      fullName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setModalState(() {
                                selectedTenantId = newValue;
                              });
                            },
                          ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: invoiceController,
                        decoration: InputDecoration(
                          labelText: 'Invoice Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an invoice number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount (₱)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Amount must be greater than zero';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () async {
                          await updatePayment(
                            context,
                            int.parse(payment.id),
                            selectedTenantId!,
                            amountController.text,
                            invoiceController.text,
                          );

                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            _fetchPayments();
                          }
                        },
                        child: Text('Update Payment'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
              onPressed: () async {
                await deletePayment(context, payment.id);

                Navigator.of(context).pop();

                _fetchPayments();
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
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(_error!, style: TextStyle(fontSize: 16)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchPayments,
                            child: Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                    : _filteredPayments.isEmpty
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
                    : RefreshIndicator(
                      onRefresh: _fetchPayments,
                      child: ListView.builder(
                        itemCount: _filteredPayments.length,
                        itemBuilder: (context, index) {
                          final payment = _filteredPayments[index];
                          return _buildPaymentCard(payment);
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPaymentModal();
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
                  'John Smith',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'john.smith@example.com',
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
                      (context) => DashboardScreen(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('House Types'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => HouseTypesScreen(
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
                      (context) => HousesScreen(
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
                      (context) => TenantScreen(
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
                      (context) => ReportsScreen(
                        toggleTheme: widget.toggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Users'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => UsersScreen(
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
            onTap: () async {
              bool confirm = await _showLogoutConfirmationDialog();
              if (confirm) {
                await _performLogout();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Logout'),
              content: Text(
                'Are you sure you want to logout? All local data will be cleared.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _performLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      await Hive.box('myBox').clear();

      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder:
              (context) => LoginScreen(
                toggleTheme: widget.toggleTheme,
                isDarkMode: widget.isDarkMode,
              ),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during logout: $e')));
    }
  }




}
