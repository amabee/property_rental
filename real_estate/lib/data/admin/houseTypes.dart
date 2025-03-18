import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate/util/links.dart';

Future<List<dynamic>?> getHouseTypes() async {
  Links link = Links();

  final query = {"operation": "getCategories", "json": jsonEncode([])};

  try {
    final response = await http.get(
      Uri.parse(link.admin_link).replace(queryParameters: query),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      print("HouseTypes Data: $res");

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

Future<void> addCategory(BuildContext context, String categoryName) async {
  Links link = Links();
  final Map<String, dynamic> jsonData = {"name": categoryName};

  final Map<String, String> queryParams = {
    "operation": "createCategory",
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
        ).showSnackBar(SnackBar(content: Text("Failed to add category")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Category added successfully!")));
        getHouseTypes();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding category")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while adding category")),
    );
  }
}

Future<void> updateCategory(
  BuildContext context,
  String categoryId,
  String categoryName,
) async {
  Links link = Links();
  final Map<String, dynamic> jsonData = {
    "id": categoryId,
    "name": categoryName,
  };

  final Map<String, String> queryParams = {
    "operation": "updateCategory",
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
        ).showSnackBar(SnackBar(content: Text("Failed to update category")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category updated successfully!")),
        );
        getHouseTypes();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating category")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while updating category")),
    );
  }
}

Future<void> deleteCategory(BuildContext context, String categoryId) async {
  Links link = Links();
  final Map<String, dynamic> jsonData = {"id": categoryId};

  final Map<String, String> queryParams = {
    "operation": "deleteCategory",
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
        ).showSnackBar(SnackBar(content: Text("Failed to delete category")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category deleted successfully!")),
        );
        getHouseTypes();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting category")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while deleting category")),
    );
  }
}
