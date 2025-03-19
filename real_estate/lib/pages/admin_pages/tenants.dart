import 'package:flutter/material.dart';
import 'package:real_estate/data/admin/houses.dart';
import 'package:real_estate/data/admin/tenants.dart';
import 'package:real_estate/models/tenant.dart';
import 'package:real_estate/pages/admin_pages/dashboard.dart';
import 'package:real_estate/pages/admin_pages/houses.dart';
import 'package:real_estate/pages/admin_pages/house_types.dart';
import 'package:real_estate/pages/admin_pages/payments.dart';
import 'package:real_estate/pages/admin_pages/reports.dart';
import 'package:real_estate/pages/admin_pages/users.dart';
import 'package:real_estate/pages/login_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TenantScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  TenantScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _TenantScreenState createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  final List<Tenant> _tenants = [];
  bool _isLoading = true;
  List<dynamic> _houses = [];

  @override
  void initState() {
    super.initState();
    _fetchTenants();
    _fetchHouses();
  }

  Future<void> _fetchHouses() async {
    final housesData = await getHouses();
    if (housesData != null) {
      setState(() {
        _houses = housesData;
      });
    }
  }

  Future<void> _fetchTenants() async {
    setState(() {
      _isLoading = true;
    });

    final tenantsData = await getTenants();

    if (tenantsData != null) {
      setState(() {
        _tenants.clear();
        _tenants.addAll(
          tenantsData.map(
            (data) => Tenant(
              id: data['id'].toString(),
              firstname: data['firstname'].toString(),
              middlename: data['middlename'].toString(),
              lastname: data['lastname'].toString(),
              email: data['email'].toString(),
              contact: data['contact'].toString(),
              houseID: data['house_id'].toString(),
              status: data['status_text'].toString(),
              dateIn: data['date_in'].toString(),
              houseNo: data['house_no'].toString(),
              monthlyRent:
                  data['monthly_rent'] is num ? data['monthly_rent'] : 0.0,
              payable: data['payable'] is num ? data['payable'] : 0.0,
              paid: data['paid'] is num ? data['paid'] : 0.0,
              lastPayment: data['last_payment'].toString(),
              outstanding:
                  data['outstanding'] is num ? data['outstanding'] : 0.0,
            ),
          ),
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load tenants')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tenants'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchTenants,
                child: _buildTenantList(_tenants),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTenantDialog(context);
        },
        child: Icon(Icons.add),
      ),
      drawer: Drawer(
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
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => PaymentsScreen(
                          toggleTheme: widget.toggleTheme,
                          isDarkMode: widget.isDarkMode,
                        ),
                  ),
                );
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
              leading: Icon(Icons.people),
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
      ),
    );
  }

  Widget _buildTenantList(List<Tenant> tenants) {
    return tenants.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_alt_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('No tenants found', style: TextStyle(fontSize: 18)),
            ],
          ),
        )
        : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: tenants.length,
          itemBuilder: (context, index) {
            final tenant = tenants[index];
            return TenantCard(
              tenant: tenant,
              isDarkMode: widget.isDarkMode,
              onView: () => _showViewTenantDialog(context, tenant),
              onEdit: () => _showEditTenantDialog(context, tenant),
              onDelete: () => _showDeleteConfirmationDialog(context, tenant),
            );
          },
        );
  }

  void _showViewTenantDialog(BuildContext context, Tenant tenant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tenant Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  'Full Name',
                  '${tenant.firstname} ${tenant.middlename} ${tenant.lastname}',
                ),
                _buildDetailRow('Email', tenant.email),
                _buildDetailRow('Phone', tenant.contact),
                _buildDetailRow('Property ID', tenant.houseID),
                _buildDetailRow('House No', tenant.houseNo),
                _buildDetailRow('Date In', tenant.dateIn),
                _buildDetailRow(
                  'Monthly Rent',
                  '₱${tenant.monthlyRent.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Payable',
                  '₱${tenant.payable.toStringAsFixed(2)}',
                ),
                _buildDetailRow('Paid', '₱${tenant.paid.toStringAsFixed(2)}'),
                _buildDetailRow(
                  'Outstanding',
                  '₱${tenant.outstanding.toStringAsFixed(2)}',
                ),
                _buildDetailRow('Last Payment', tenant.lastPayment),
                _buildDetailRow('Status', tenant.status),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditTenantDialog(BuildContext context, Tenant tenant) {
    final firstnameController = TextEditingController(text: tenant.firstname);
    final middlenameController = TextEditingController(text: tenant.middlename);
    final lastnameController = TextEditingController(text: tenant.lastname);
    final emailController = TextEditingController(text: tenant.email);
    final contactController = TextEditingController(text: tenant.contact);
    final rentController = TextEditingController(
      text: tenant.monthlyRent.toString(),
    );
    String status = tenant.status;
    String selectedHouseId = tenant.houseID;

    // Find the house in our list that matches the tenant's house ID
    dynamic selectedHouse = _houses.firstWhere(
      (house) => house['id'].toString() == selectedHouseId,
      orElse: () => null,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Tenant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstnameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: middlenameController,
                  decoration: InputDecoration(labelText: 'Middle Name'),
                ),
                TextField(
                  controller: lastnameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedHouseId,
                  decoration: InputDecoration(labelText: 'House'),
                  isExpanded: true,
                  items:
                      _houses.map<DropdownMenuItem<String>>((house) {
                        return DropdownMenuItem<String>(
                          value: house['id'].toString(),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(
                              "House #${house['house_no']} - ${house['description']}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    selectedHouseId = value!;
                    selectedHouse = _houses.firstWhere(
                      (house) => house['id'].toString() == value,
                      orElse: () => null,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await updateTenant(
                  context,
                  int.parse(tenant.id),
                  firstnameController.text,
                  middlenameController.text,
                  lastnameController.text,
                  emailController.text,
                  contactController.text,
                  selectedHouseId,
                );

                await _fetchTenants();

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Tenant tenant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Tenant'),
          content: Text(
            'Are you sure you want to delete ${tenant.firstname} ${tenant.lastname}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // setState(() {
                //   _tenants.removeWhere((t) => t.id == tenant.id);
                // });
                await deleteTenant(context, tenant.id);
                _fetchTenants();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tenant deleted successfully')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTenantDialog(BuildContext context) {
    final firstnameController = TextEditingController();
    final middlenameController = TextEditingController();
    final lastnameController = TextEditingController();
    final emailController = TextEditingController();
    final contactController = TextEditingController();
    String? selectedHouseId;
    dynamic selectedHouse;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Tenant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstnameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: middlenameController,
                  decoration: InputDecoration(labelText: 'Middle Name'),
                ),
                TextField(
                  controller: lastnameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedHouseId,
                  decoration: InputDecoration(labelText: 'House'),
                  hint: Text('Select a house'),
                  isExpanded: true,
                  items:
                      _houses.map<DropdownMenuItem<String>>((house) {
                        return DropdownMenuItem<String>(
                          value: house['id'].toString(),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(
                              "House #${house['house_no']} - ${house['description']}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    selectedHouseId = value;
                    selectedHouse = _houses.firstWhere(
                      (house) => house['id'].toString() == value,
                      orElse: () => null,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedHouseId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a house')),
                  );
                  return;
                }
                await addTenants(
                  context,
                  firstnameController.text,
                  middlenameController.text,
                  lastnameController.text,
                  emailController.text,
                  contactController.text,
                  selectedHouseId,
                );
                await _fetchTenants();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final bool isDarkMode;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  TenantCard({
    required this.tenant,
    required this.isDarkMode,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Text(
                        tenant.firstname.isNotEmpty
                            ? tenant.firstname[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tenant.firstname} ${tenant.lastname}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            tenant.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(tenant.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tenant.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.home, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'House #${tenant.houseNo}',
                        style: TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Date In: ${tenant.dateIn}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '₱${tenant.monthlyRent.toStringAsFixed(2)}/month',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Outstanding: ₱${tenant.outstanding.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            tenant.outstanding > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onView,
                        child: Text('View'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onEdit,
                        child: Text('Edit'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'current':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
