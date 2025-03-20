import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate/util/links.dart';

Future<List<dynamic>?> getHouses() async {
  Links link = Links();

  final query = {"operation": "viewHouses", "json": jsonEncode([])};

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

Future<void> addHouse(
  BuildContext context,
  String houseNo,
  String category,
  String description,
  int price,
  File? selectedImage,
) async {
  Links link = Links();

  final Map<String, dynamic> jsonData = {
    "house_no": houseNo,
    "category_id": category,
    "description": description,
    "price": price,
  };

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(link.admin_link).replace(
      queryParameters: {"operation": "addHouse", "json": jsonEncode(jsonData)},
    ),
  );

  if (selectedImage != null) {
    request.files.add(
      await http.MultipartFile.fromPath('image', selectedImage.path),
    );
  }
  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  try {
    if (response.statusCode == 200) {
      final res = jsonDecode(responseBody);

      print("RES: $res");

      if (res == "0") {
        print("Failed to add house");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to add house")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("House added successfully!")));
        getHouses();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding house")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    print("RESPONSE: $responseBody");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Network error while adding house")));
  }
}

Future<void> updateHouse(
  BuildContext context,
  int id,
  String houseNo,
  String category,
  String description,
  int price,
  File? selectedImage,
) async {
  Links link = Links();

  final Map<String, dynamic> jsonData = {
    "id" : id,
    "house_no": houseNo,
    "category_id": category,
    "description": description,
    "price": price,
  };

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(link.admin_link).replace(
      queryParameters: {
        "operation": "updateHouse",
        "json": jsonEncode(jsonData),
      },
    ),
  );

  if (selectedImage != null) {
    request.files.add(
      await http.MultipartFile.fromPath('image', selectedImage.path),
    );
  }
  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  print(responseBody);
  try {
    if (response.statusCode == 200) {
      final res = jsonDecode(responseBody);

      print("RES: $res");

      if (res == "0") {
        print("Failed to update house");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update house")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("House updated successfully!")));
        getHouses();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating house")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    print("RESPONSE: $responseBody");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while updating house")),
    );
  }
}

Future<void> deleteHouse(BuildContext context, String houseId) async {
  Links link = Links();

  final Map<String, String> queryParams = {
    "operation": "deleteHouse",
    "json": jsonEncode({"id": houseId}),
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
        ).showSnackBar(SnackBar(content: Text("Failed to delete house")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("House deleted successfully!")));
        getHouses();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting house")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while deleting house")),
    );
  }
}
