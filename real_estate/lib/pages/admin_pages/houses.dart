import 'package:flutter/material.dart';
import 'package:real_estate/models/propert.dart';
import 'package:real_estate/pages/admin_pages/dashboard.dart';
import 'package:real_estate/pages/admin_pages/house_types.dart';
import 'package:real_estate/pages/admin_pages/payments.dart';
import 'package:real_estate/pages/admin_pages/reports.dart';
import 'package:real_estate/pages/admin_pages/tenants.dart';
import 'package:real_estate/pages/admin_pages/users.dart';
import 'package:real_estate/pages/login_page.dart';

class HousesScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  HousesScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _HousesScreenState createState() => _HousesScreenState();
}

class _HousesScreenState extends State<HousesScreen> {
  final List<Property> _houses = [
    Property(
      id: '1',
      title: 'Modern Villa with Pool',
      address: '123 Main St, Cityville',
      price: 750000,
      bedrooms: 4,
      bathrooms: 3,
      area: 2500,
      imageUrl: 'https://via.placeholder.com/300',
      isAvailable: true,
    ),
    Property(
      id: '2',
      title: 'Downtown Apartment',
      address: '456 Center Ave, Metropolis',
      price: 350000,
      bedrooms: 2,
      bathrooms: 2,
      area: 1200,
      imageUrl: 'https://via.placeholder.com/300',
      isAvailable: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Houses'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: _buildHousesList(_houses),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new house action
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Add new house')));
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
              leading: Icon(Icons.category),
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
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
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

  Widget _buildHousesList(List<Property> houses) {
    return houses.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('No houses found', style: TextStyle(fontSize: 18)),
            ],
          ),
        )
        : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: houses.length,
          itemBuilder: (context, index) {
            final house = houses[index];
            return HouseCard(house: house, isDarkMode: widget.isDarkMode);
          },
        );
  }
}

// House Card Widget
class HouseCard extends StatelessWidget {
  final Property house;
  final bool isDarkMode;

  HouseCard({required this.house, required this.isDarkMode});

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
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.home,
                      size: 80,
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: house.isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    house.isAvailable ? 'AVAILABLE' : 'RENTED',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        house.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₱${house.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        house.address,
                        style: TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // View details action
                        },
                        child: Text('View Details'),
                      ),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        // Edit house action
                      },
                      child: Text('Edit'),
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
}
