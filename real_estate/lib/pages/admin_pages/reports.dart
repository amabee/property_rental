import 'package:flutter/material.dart';
import 'package:real_estate/pages/admin_pages/ui/monthlyReportsPage.dart';
import 'package:real_estate/pages/admin_pages/ui/rentalBalancesPage.dart';
import 'package:real_estate/pages/admin_pages/dashboard.dart';
import 'package:real_estate/pages/admin_pages/house_types.dart';
import 'package:real_estate/pages/admin_pages/houses.dart';
import 'package:real_estate/pages/admin_pages/payments.dart';
import 'package:real_estate/pages/admin_pages/tenants.dart';
import 'package:real_estate/pages/admin_pages/users.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:real_estate/pages/login_page.dart';

class ReportsScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const ReportsScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildReportCard(
                context,
                'Monthly Payments Report',
                'View detailed information about monthly payments and transactions',
                Icons.insert_chart,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MonthlyPaymentsReportPage(
                            toggleTheme: widget.toggleTheme,
                            isDarkMode: widget.isDarkMode,
                          ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildReportCard(
                context,
                'Rental Balances Report',
                'Check outstanding balances and payment status for all rentals',
                Icons.account_balance_wallet,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RentalBalancesReportPage(
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
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 36, color: color),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('View Report'),
              ),
            ),
          ],
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
            selected: true,
            onTap: () {
              Navigator.pop(context);
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
