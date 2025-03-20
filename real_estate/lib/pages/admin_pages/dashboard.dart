import 'package:flutter/material.dart';
import 'package:real_estate/data/queries/getDashboardData.dart';
import 'package:real_estate/pages/admin_pages/house_types.dart';
import 'package:real_estate/pages/admin_pages/houses.dart';
import 'package:real_estate/pages/admin_pages/payments.dart';
import 'package:real_estate/pages/admin_pages/reports.dart';
import 'package:real_estate/pages/admin_pages/tenants.dart';
import 'package:real_estate/pages/admin_pages/users.dart';
import 'package:real_estate/pages/login_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const DashboardScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalHouses = 0;
  int totalTenants = 0;
  double paymentsThisMonth = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final data = await getDashboardData();

    if (data != null) {
      setState(() {
        totalHouses = data['house_count'] ?? 0;
        totalTenants = data['tenant_count'] ?? 0;
        paymentsThisMonth = (data['payments_this_month'] ?? 0.0).toDouble();
      });
    } else {
      print("Failed to fetch dashboard data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
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
                'Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                mainAxisSpacing: 16,
                children: [
                  _buildSummaryCard(
                    context,
                    'Total Houses',
                    totalHouses.toString(),
                    Icons.home,
                    Colors.blue,
                  ),
                  _buildSummaryCard(
                    context,
                    'Total Tenants',
                    totalTenants.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                  _buildSummaryCard(
                    context,
                    'Payments This Month',
                    '₱${paymentsThisMonth.toStringAsFixed(2)}',
                    Icons.payments,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'New Tenant Registration',
        'description': 'James Wilson registered as a tenant',
        'time': '2 hours ago',
        'icon': Icons.person_add,
        'color': Colors.green,
      },
      {
        'title': 'Payment Received',
        'description': 'Payment of ₱8,500 received from Maria Garcia',
        'time': '4 hours ago',
        'icon': Icons.payments,
        'color': Colors.blue,
      },
      {
        'title': 'Property Listed',
        'description': 'New property at 789 Pine St. has been listed',
        'time': '1 day ago',
        'icon': Icons.home,
        'color': Colors.purple,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: activity['color'].withOpacity(0.2),
              child: Icon(activity['icon'], color: activity['color']),
            ),
            title: Text(activity['title']),
            subtitle: Text(activity['description']),
            trailing: Text(
              activity['time'],
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        );
      },
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
            selected: true,
            onTap: () {
              Navigator.pop(context);
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
