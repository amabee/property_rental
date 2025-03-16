import 'package:flutter/material.dart';
import 'package:real_estate/models/propert.dart';
import 'package:real_estate/pages/login_page.dart';

class HomeScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  HomeScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Property> _myProperties = [
    Property(
      id: '1',
      title: 'Modern Villa with Pool',
      address: '123 Main St, Cityville',
      price: 750000,
      bedrooms: 4,
      bathrooms: 3,
      area: 2500,
      imageUrl: 'https://via.placeholder.com/300',
      isFavorite: true,
      isMyProperty: true,
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
      isFavorite: false,
      isMyProperty: true,
    ),
  ];

  final List<Property> _marketProperties = [
    Property(
      id: '3',
      title: 'Suburban Family Home',
      address: '789 Oak Rd, Greentown',
      price: 520000,
      bedrooms: 3,
      bathrooms: 2,
      area: 1800,
      imageUrl: 'https://via.placeholder.com/300',
      isFavorite: true,
      isMyProperty: false,
    ),
    Property(
      id: '4',
      title: 'Beachfront Condo',
      address: '101 Coast Blvd, Seaside',
      price: 850000,
      bedrooms: 3,
      bathrooms: 3,
      area: 2000,
      imageUrl: 'https://via.placeholder.com/300',
      isFavorite: false,
      isMyProperty: false,
    ),
    Property(
      id: '5',
      title: 'Mountain Retreat',
      address: '222 Pine Pass, Highland',
      price: 450000,
      bedrooms: 2,
      bathrooms: 2,
      area: 1500,
      imageUrl: 'https://via.placeholder.com/300',
      isFavorite: false,
      isMyProperty: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFavorite(Property property) {
    setState(() {
      property.isFavorite = !property.isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          property.isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Marketplace'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'My Properties'), Tab(text: 'Marketplace')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Properties Tab
          _buildPropertyList(_myProperties),

          // Marketplace Tab
          _buildPropertyList(_marketProperties),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new property action
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Add new property')));
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
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
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

  Widget _buildPropertyList(List<Property> properties) {
    return properties.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('No properties found', style: TextStyle(fontSize: 18)),
            ],
          ),
        )
        : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return PropertyCard(
              property: property,
              onFavoriteToggle: () => _toggleFavorite(property),
              isDarkMode: widget.isDarkMode,
            );
          },
        );
  }
}

// Property Card Widget
class PropertyCard extends StatelessWidget {
  final Property property;
  final Function onFavoriteToggle;
  final bool isDarkMode;

  PropertyCard({
    required this.property,
    required this.onFavoriteToggle,
    required this.isDarkMode,
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
                right: 10,
                child: CircleAvatar(
                  backgroundColor:
                      isDarkMode
                          ? Colors.black.withOpacity(0.6)
                          : Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(
                      property.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: property.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => onFavoriteToggle(),
                  ),
                ),
              ),
              if (property.isMyProperty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'MY PROPERTY',
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
                        property.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₱${property.price.toStringAsFixed(0)}',
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
                        property.address,
                        style: TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeature(
                      context,
                      Icons.king_bed_outlined,
                      '${property.bedrooms} Beds',
                    ),
                    _buildFeature(
                      context,
                      Icons.bathtub_outlined,
                      '${property.bathrooms} Baths',
                    ),
                    _buildFeature(
                      context,
                      Icons.straighten,
                      '${property.area} sqft',
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
                        // Contact owner action
                      },
                      child: Text(property.isMyProperty ? 'Edit' : 'Contact'),
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

  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        SizedBox(height: 4),
        Text(text),
      ],
    );
  }
}
