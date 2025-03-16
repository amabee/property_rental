import 'package:flutter/material.dart';
import 'package:real_estate/models/tenant.dart';
import 'package:real_estate/pages/admin_pages/admin_home.dart';
import 'package:real_estate/pages/admin_pages/house_types.dart';
import 'package:real_estate/pages/login_page.dart';

class TenantScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  TenantScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _TenantScreenState createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  final List<Tenant> _tenants = [
    Tenant(
      id: '1',
      name: 'Sarah Johnson',
      email: 'sarah.johnson@example.com',
      phone: '+1 (555) 123-4567',
      propertyId: '1',
      propertyName: 'Modern Villa with Pool',
      leaseStart: DateTime(2023, 5, 1),
      leaseEnd: DateTime(2024, 5, 1),
      monthlyRent: 3500,
      depositPaid: true,
      paymentStatus: 'Current',
    ),
    Tenant(
      id: '2',
      name: 'Michael Chen',
      email: 'michael.chen@example.com',
      phone: '+1 (555) 987-6543',
      propertyId: '2',
      propertyName: 'Downtown Apartment',
      leaseStart: DateTime(2023, 3, 15),
      leaseEnd: DateTime(2024, 3, 15),
      monthlyRent: 2200,
      depositPaid: true,
      paymentStatus: 'Late',
    ),
  ];

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
      body: _buildTenantList(_tenants),
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
                        (context) => AdminHomeScreen(
                          toggleTheme: widget.toggleTheme,
                          isDarkMode: widget.isDarkMode,
                        ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Tenants'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payments'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.data_exploration_rounded),
              title: Text('Reports'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Users'),
              onTap: () {
                Navigator.pop(context);
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
                _buildDetailRow('Name', tenant.name),
                _buildDetailRow('Email', tenant.email),
                _buildDetailRow('Phone', tenant.phone),
                _buildDetailRow('Property', tenant.propertyName),
                _buildDetailRow('Lease Start', _formatDate(tenant.leaseStart)),
                _buildDetailRow('Lease End', _formatDate(tenant.leaseEnd)),
                _buildDetailRow(
                  'Monthly Rent',
                  '₱${tenant.monthlyRent.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Deposit Paid',
                  tenant.depositPaid ? 'Yes' : 'No',
                ),
                _buildDetailRow('Payment Status', tenant.paymentStatus),
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
    final nameController = TextEditingController(text: tenant.name);
    final emailController = TextEditingController(text: tenant.email);
    final phoneController = TextEditingController(text: tenant.phone);
    final rentController = TextEditingController(
      text: tenant.monthlyRent.toString(),
    );
    String paymentStatus = tenant.paymentStatus;
    bool depositPaid = tenant.depositPaid;

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
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: rentController,
                  decoration: InputDecoration(labelText: 'Monthly Rent'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: paymentStatus,
                  decoration: InputDecoration(labelText: 'Payment Status'),
                  items:
                      ['Current', 'Late', 'Overdue'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    paymentStatus = value!;
                  },
                ),
                CheckboxListTile(
                  title: Text('Deposit Paid'),
                  value: depositPaid,
                  onChanged: (value) {
                    depositPaid = value!;
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
              onPressed: () {
                // Update tenant logic here
                setState(() {
                  tenant.name = nameController.text;
                  tenant.email = emailController.text;
                  tenant.phone = phoneController.text;
                  tenant.monthlyRent = double.parse(rentController.text);
                  tenant.paymentStatus = paymentStatus;
                  tenant.depositPaid = depositPaid;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tenant updated successfully')),
                );
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
          content: Text('Are you sure you want to delete ${tenant.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tenants.removeWhere((t) => t.id == tenant.id);
                });
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
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final propertyController = TextEditingController();
    final rentController = TextEditingController();
    String paymentStatus = 'Current';
    bool depositPaid = false;

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
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: propertyController,
                  decoration: InputDecoration(labelText: 'Property'),
                ),
                TextField(
                  controller: rentController,
                  decoration: InputDecoration(labelText: 'Monthly Rent'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: paymentStatus,
                  decoration: InputDecoration(labelText: 'Payment Status'),
                  items:
                      ['Current', 'Late', 'Overdue'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    paymentStatus = value!;
                  },
                ),
                CheckboxListTile(
                  title: Text('Deposit Paid'),
                  value: depositPaid,
                  onChanged: (value) {
                    depositPaid = value!;
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
              onPressed: () {
                // Add new tenant logic
                setState(() {
                  _tenants.add(
                    Tenant(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      propertyId: '3',
                      propertyName: propertyController.text,
                      leaseStart: DateTime.now(),
                      leaseEnd: DateTime.now().add(Duration(days: 365)),
                      monthlyRent: double.tryParse(rentController.text) ?? 0,
                      depositPaid: depositPaid,
                      paymentStatus: paymentStatus,
                    ),
                  );
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tenant added successfully')),
                );
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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
                        tenant.name.isNotEmpty
                            ? tenant.name[0].toUpperCase()
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
                            tenant.name,
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
                    color: _getStatusColor(tenant.paymentStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tenant.paymentStatus.toUpperCase(),
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
                        tenant.propertyName,
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
                      'Lease: ${_formatDate(tenant.leaseStart)} - ${_formatDate(tenant.leaseEnd)}',
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
                    SizedBox(width: 16),
                    Icon(Icons.security, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Deposit: ${tenant.depositPaid ? 'Paid' : 'Unpaid'}',
                      style: TextStyle(color: Colors.grey),
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
