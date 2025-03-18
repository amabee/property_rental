import 'dart:convert';
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

Future<bool> createHouse(Map<String, dynamic> houseData) async {
  Links link = Links();

  final body = {"operation": "addHouse", "json": jsonEncode(houseData)};

  try {
    final response = await http.post(
      Uri.parse(link.admin_link),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['success'] != null;
    }
  } catch (error) {
    print("Error adding house: $error");
  }
  return false;
}

Future<bool> updateHouse(Map<String, dynamic> updatedData) async {
  Links link = Links();

  final body = {"operation": "updateHouse", "json": jsonEncode(updatedData)};

  try {
    final response = await http.post(
      Uri.parse(link.admin_link),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['success'] != null;
    }
  } catch (error) {
    print("Error updating house: $error");
  }
  return false;
}

Future<bool> deleteHouse(String houseId) async {
  Links link = Links();

  final body = {
    "operation": "deleteHouse",
    "json": jsonEncode({"id": houseId}),
  };

  try {
    final response = await http.post(
      Uri.parse(link.admin_link),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['success'] != null;
    }
  } catch (error) {
    print("Error deleting house: $error");
  }
  return false;
}
