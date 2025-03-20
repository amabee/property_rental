import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate/util/links.dart';

Future<List<dynamic>?> getTenants() async {
  Links link = Links();

  final query = {"operation": "viewTenants", "json": jsonEncode([])};

  try {
    final response = await http.get(
      Uri.parse(link.admin_link).replace(queryParameters: query),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      print("TENANTS: $res");

      if (res is List) {
        return res;
      } else {
        print("Invalid data format received from API");
        return null;
      }
    }
  } catch (error) {
    print("Runtime Error: $error");
  }
  return null;
}

Future<void> addTenants(
  BuildContext context,
  String firstname,
  String middlename,
  String lastname,
  String email,
  String contact,
  String? house_id,
) async {
  Links link = Links();

  final Map<String, dynamic> jsonData = {
    "firstname": firstname,
    "middlename": middlename,
    "lastname": lastname,
    "email": email,
    "contact": contact,
    "house_id": house_id,
  };

  final Map<String, String> queryParams = {
    "operation": "addTenant",
    "json": jsonEncode(jsonData),
  };

  try {
    final response = await http.post(
      Uri.parse(link.admin_link).replace(queryParameters: queryParams),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      if (res == "0") {
        print("Something went wrong");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to add tenant")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Tenant added successfully!")));
        getTenants();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding tenant")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while adding tenant")),
    );
  }
}

Future<void> updateTenant(
  BuildContext context,
  int id,
  String firstname,
  String middlename,
  String lastname,
  String email,
  String contact,
  String? house_id,
) async {
  Links link = Links();

  final Map<String, dynamic> jsonData = {
    "id": id,
    "firstname": firstname,
    "middlename": middlename,
    "lastname": lastname,
    "email": email,
    "contact": contact,
    "house_id": house_id,
  };

  final Map<String, String> queryParams = {
    "operation": "updateTenant",
    "json": jsonEncode(jsonData),
  };

  try {
    final response = await http.post(
      Uri.parse(link.admin_link).replace(queryParameters: queryParams),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      if (res == "0") {
        print("Something went wrong");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to add tenant")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Tenant added successfully!")));
        getTenants();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding tenant")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while adding tenant")),
    );
  }
}

Future<void> deleteTenant(BuildContext context, String tenantId) async {
  Links link = Links();

  final Map<String, String> queryParams = {
    "operation": "deleteTenant",
    "json": jsonEncode({"id": tenantId}),
  };

  try {
    final response = await http.post(
      Uri.parse(link.admin_link).replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      if (res == "error") {
        print("Failed to delete house");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete tenant")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Tenant deleted successfully!")));
        getTenants();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting tenant")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while deleting tenant")),
    );
  }
}
