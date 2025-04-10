import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_estate/data/queries/houseTypes.dart';
import 'package:real_estate/data/queries/houses.dart';
import 'package:real_estate/models/propert.dart';

import 'package:real_estate/pages/staff_pages/dashboard.dart';
import 'package:real_estate/pages/staff_pages/house_types.dart';
import 'package:real_estate/pages/staff_pages/payments.dart';
import 'package:real_estate/pages/staff_pages/reports.dart';
import 'package:real_estate/pages/staff_pages/tenants.dart';
import 'package:real_estate/pages/login_page.dart';
import 'package:real_estate/util/links.dart';

class StaffHousesScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  StaffHousesScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _StaffHousesScreenState createState() => _StaffHousesScreenState();
}

class _StaffHousesScreenState extends State<StaffHousesScreen> {
  List<Property> _houses = [];
  List<Map<String, dynamic>> _houseTypeOptions = [];

  bool _isLoading = true;

  String userName = "User";
  String userUsername = "";

  @override
  void initState() {
    super.initState();
    _fetchHouses();
    _fetchHouseTypes();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final box = Hive.box('myBox');
      final name = box.get('name');
      final username = box.get('username');

      print(box);

      if (name != null) {
        setState(() {
          userName = name;
          userUsername = username ?? "";
        });
      }
    } catch (e) {
      print("Error retrieving user data: $e");
    }
  }

  Future<void> _fetchHouses() async {
    final houseData = await getHouses();

    if (houseData != null) {
      setState(() {
        _houses =
            houseData
                .map(
                  (house) => Property(
                    id: house['id'].toString(),
                    houseNo: house['house_no'].toString(),
                    category: house['category_name'].toString(),
                    description: house['description'].toString(),
                    image: house['image'].toString(),
                    price: house['price'] ?? 0.00,
                    isAvailable: house['isAvailable'] ?? true,
                  ),
                )
                .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load houses.')));
    }
  }

  Future<void> _fetchHouseTypes() async {
    final houseTypesData = await getHouseTypes();

    if (houseTypesData != null) {
      setState(() {
        _houseTypeOptions =
            houseTypesData
                .map<Map<String, dynamic>>(
                  (type) => {'id': type['id'], 'name': type['name']},
                )
                .toList();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load house types.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Houses'),
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
          _showAddHouseModal(context);
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
                    userName,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    userUsername,
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
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => StaffPaymentsScreen(
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
            return HouseCard(
              house: house,
              isDarkMode: widget.isDarkMode,
              onViewDetails: _showHouseDetailsModal,
              onEdit: _showEditHouseModal,
            );
          },
        );
  }

  void _showAddHouseModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String houseNo = '';
    String description = '';
    String category = '';
    int price = 0;
    File? selectedImage;
    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New House'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'House No',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter house number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          houseNo = value;
                        },
                      ),
                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value:
                            _houseTypeOptions.isNotEmpty
                                ? _houseTypeOptions[0]['id'].toString()
                                : null,
                        items:
                            _houseTypeOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option['id'].toString(),
                                child: Text(option['name']),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            category = newValue!;
                          });
                          print("CATEGORY ID: $newValue");
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Price
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: '₱ ',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          price = int.parse(value);
                        },
                      ),
                      SizedBox(height: 16),

                      // Description
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          description = value;
                        },
                      ),
                      SizedBox(height: 16),

                      // Image Selection
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            selectedImage != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text('No image selected'),
                                    ],
                                  ),
                                ),
                      ),
                      SizedBox(height: 8),

                      // Image picker button
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _pickImage();
                          setState(() {});
                        },
                        icon: Icon(Icons.photo_library),
                        label: Text('Select Image'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                        ),
                      ),
                    ],
                  ),
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
                    if (_formKey.currentState!.validate()) {
                      await addHouse(
                        context,
                        houseNo,
                        category,
                        description,
                        price,
                        selectedImage,
                      );
                      Navigator.of(context).pop();
                      _fetchHouses();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHouseDetailsModal(BuildContext context, Property house) {
    Links link = Links();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          house.image.startsWith('http')
                              ? house.image
                              : '${link.imglink}/${house.image}',
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (context, child, loadingProgress) =>
                                  (loadingProgress == null)
                                      ? child
                                      : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                          errorBuilder:
                              (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.7),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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

                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              house.houseNo,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis
                              ),
                            ),
                            Text(
                              '₱${house.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            house.category,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          house.description,
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Property Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow('ID', house.id),
                        _buildDetailRow('House Title', house.houseNo),
                        _buildDetailRow('Category', house.category),
                        _buildDetailRow(
                          'Price',
                          '₱${house.price.toStringAsFixed(0)}',
                        ),
                        _buildDetailRow(
                          'Status',
                          house.isAvailable ? 'Available' : 'Rented',
                        ),
                        SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showDeleteConfirmationDialog(context, house);
                                },
                                child: Text('Delete Property'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Property house) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Property'),
          content: Text(
            'Are you sure you want to delete ${house.houseNo}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteHouse(context, house.id);
                _fetchHouses();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _showEditHouseModal(BuildContext context, Property house) {
    final _formKey = GlobalKey<FormState>();
    String houseNo = house.houseNo;
    String description = house.description;

    String? category =
        _houseTypeOptions
            .firstWhere(
              (type) => type['name'] == house.category,
              orElse: () => {'id': null},
            )['id']
            ?.toString();

    int price = house.price.toInt();
    bool isAvailable = house.isAvailable;
    File? selectedImage;
    final ImagePicker _picker = ImagePicker();
    Links link = Links();

    Future<void> _pickImage() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage = File(image.path);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit House'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: houseNo,
                        decoration: InputDecoration(
                          labelText: 'House No',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter house number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          houseNo = value;
                        },
                      ),
                      SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: category,
                        items:
                            _houseTypeOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option['id'].toString(),
                                child: Text(
                                  option['name'],
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            category = newValue!;
                          });

                          print("NEW VALUE: $newValue");
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        initialValue: price.toString(),
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: '₱ ',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          price = int.parse(value);
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        initialValue: description,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          description = value;
                        },
                      ),
                      SizedBox(height: 16),

                      if (selectedImage == null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Image:',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  house.image.startsWith('http')
                                      ? house.image
                                      : '${link.imglink}/${house.image}',
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) =>
                                          (loadingProgress == null)
                                              ? child
                                              : Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                  errorBuilder:
                                      (context, error, stackTrace) => Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      if (selectedImage != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New Image:', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: () async {
                          await _pickImage();
                          setState(() {});
                        },
                        icon: Icon(Icons.photo_library),
                        label: Text('Change Image'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                        ),
                      ),
                    ],
                  ),
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
                    if (_formKey.currentState!.validate()) {
                      await updateHouse(
                        context,
                        int.parse(house.id),
                        houseNo,
                        category!,
                        description,
                        price,
                        selectedImage,
                      );
                      Navigator.of(context).pop();
                      _fetchHouses();
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
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

class HouseCard extends StatelessWidget {
  final Property house;
  final bool isDarkMode;
  final Function(BuildContext, Property) onViewDetails;
  final Function(BuildContext, Property) onEdit;

  Links link = Links();

  HouseCard({
    required this.house,
    required this.isDarkMode,
    required this.onViewDetails,
    required this.onEdit,
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
                    child: Image.network(
                      house.image.startsWith('http')
                          ? house.image
                          : '${link.imglink}/${house.image}',
                      loadingBuilder:
                          (context, child, loadingProgress) =>
                              (loadingProgress == null)
                                  ? child
                                  : CircularProgressIndicator(),
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          house.houseNo,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          house.category,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Text(
                      '₱${house.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onViewDetails(context, house);
                        },
                        child: Text('View Details'),
                      ),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        onEdit(context, house);
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
