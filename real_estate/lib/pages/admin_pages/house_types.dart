import 'package:flutter/material.dart';
import 'package:real_estate/models/house_types.dart';
import 'package:real_estate/pages/admin_pages/admin_home.dart';

class HouseTypesScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  HouseTypesScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _HouseTypesScreenState createState() => _HouseTypesScreenState();
}

class _HouseTypesScreenState extends State<HouseTypesScreen> {
  final List<HouseType> _houseTypes = [
    HouseType(
      id: '1',
      name: 'Studio',
      description: 'Single room with integrated kitchen and bathroom',
      basePrice: 150000,
      isActive: true,
    ),
    HouseType(
      id: '2',
      name: 'Apartment',
      description: 'Multi-room unit in a building complex',
      basePrice: 350000,
      isActive: true,
    ),
    HouseType(
      id: '3',
      name: 'Townhouse',
      description: 'Multi-story house connected to other similar units',
      basePrice: 450000,
      isActive: true,
    ),
    HouseType(
      id: '4',
      name: 'Bungalow',
      description: 'Single-story house with a sloping roof',
      basePrice: 550000,
      isActive: false,
    ),
    HouseType(
      id: '5',
      name: 'Villa',
      description: 'Luxury house with large yard and pool',
      basePrice: 750000,
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('House Types'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage House Types',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(child: _buildHouseTypesCards()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditHouseTypeDialog(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Add New House Type',
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildHouseTypesCards() {
    return ListView.builder(
      itemCount: _houseTypes.length,
      itemBuilder: (context, index) {
        final houseType = _houseTypes[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      houseType.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            houseType.isActive
                                ? Colors.green[100]
                                : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: houseType.isActive ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        houseType.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color:
                              houseType.isActive
                                  ? Colors.green[800]
                                  : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  houseType.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Text(
                  'Base Price: ₱${houseType.basePrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue),
                      ),
                      onPressed: () {
                        _showAddEditHouseTypeDialog(context, houseType);
                      },
                    ),
                    SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, houseType);
                      },
                    ),
                  ],
                ),
              ],
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
            leading: Icon(Icons.category),
            title: Text('House Types'),
            selected: true,
            selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
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
            leading: Icon(Icons.people),
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
              Navigator.pop(context);
              // Add logout logic here
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEditHouseTypeDialog(
    BuildContext context, [
    HouseType? houseType,
  ]) async {
    final isEditing = houseType != null;
    final nameController = TextEditingController(
      text: isEditing ? houseType.name : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? houseType.description : '',
    );
    final priceController = TextEditingController(
      text: isEditing ? houseType.basePrice.toString() : '',
    );
    bool isActive = isEditing ? houseType.isActive : true;

    return showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    isEditing ? 'Edit House Type' : 'Add New House Type',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: 'Base Price (₱)',
                            border: OutlineInputBorder(),
                            prefixText: '₱',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                        SwitchListTile(
                          title: Text('Active'),
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      child: Text(isEditing ? 'Update' : 'Add'),
                      onPressed: () {
                        // In a real app, validate inputs and save to database
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'House type updated!'
                                  : 'New house type added!',
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    HouseType houseType,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete House Type'),
            content: Text(
              'Are you sure you want to delete "${houseType.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  // In a real app, delete from database
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('House type deleted!')),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }
}
