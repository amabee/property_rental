import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate/util/links.dart';

Future<List<dynamic>?> getUsers() async {
  Links link = Links();

  final query = {"operation": "viewUsers", "json": jsonEncode([])};

  try {
    final response = await http.get(
      Uri.parse(link.admin_link).replace(queryParameters: query),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

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

Future<void> addUser(
  BuildContext context,
  String name,
  String username,
  String password,
  String type,
) async {
  Links link = Links();
  final Map<String, dynamic> jsonData = {
    "name": name,
    "username": username,
    "password": password,
    "type": type,
  };

  final Map<String, String> queryParams = {
    "operation": "addUser",
    "json": jsonEncode(jsonData),
  };

  try {
    final response = await http.post(
      Uri.parse(link.admin_link).replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      if (res == "0") {
        print("Something went wrong");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to add user")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User added successfully!")));
        getUsers();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding user")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Network error while adding user")));
  }
}

Future<void> updateUser(
  BuildContext context,
  String userid,
  String name,
  String username,
  String password,
  String type,
) async {
  Links link = Links();
  final Map<String, dynamic> jsonData = {
    "id": userid,
    "name": name,
    "username": username,
    "password": password,
    "type": type,
  };

  final Map<String, String> queryParams = {
    "operation": "updateUser",
    "json": jsonEncode(jsonData),
  };

  print("QUERY PARAMS: $queryParams");

  try {
    final response = await http.post(
      Uri.parse(link.admin_link).replace(queryParameters: queryParams),
    );

    print("RESPONSE: " + response.body);

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      if (res == "0") {
        print("Something went wrong");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update user")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User updated successfully!")));
        getUsers();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating user")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while updating user")),
    );
  }
}

Future<void> deleteUser(BuildContext context, String userid) async {
  Links link = Links();
  final Map<String, dynamic> jsonData = {"id": userid};

  final Map<String, String> queryParams = {
    "operation": "deleteUser",
    "json": jsonEncode(jsonData),
  };

  try {
    final response = await http.post(
      Uri.parse(link.admin_link).replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      if (res == "0") {
        print("Something went wrong");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete user")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User deleted successfully!")));
        getUsers();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting user")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while deleting user")),
    );
  }
}
