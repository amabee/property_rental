import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate/util/links.dart';

Future<List<dynamic>?> getPayments() async {
  Links link = Links();

  final query = {"operation": "viewPayments", "json": jsonEncode([])};

  try {
    final response = await http.get(
      Uri.parse(link.admin_link).replace(queryParameters: query),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      print("PAYMENTS: $res");

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

Future<void> addPayment(
  BuildContext context,
  String firstname,
  String middlename,
  String lastname,
  String email,
  String contact,
  String? house_id,
) async {
  Links link = Links();

  final Map<String, dynamic> jsonData = {};

  final Map<String, String> queryParams = {
    "operation": "addPayment",
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
        ).showSnackBar(SnackBar(content: Text("Failed to add payment")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Payment added successfully!")));
        getPayments();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding payment")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while adding payment")),
    );
  }
}
