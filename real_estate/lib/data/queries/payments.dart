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
  String tenantId,
  String amount,
  String invoice,
) async {
  Links link = Links();

  final Map<String, dynamic> jsonData = {
    "tenant_id": tenantId,
    "amount": amount,
    "invoice": invoice,
  };

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

Future<void> updatePayment(
  BuildContext context,
  int id,
  String tenantId,
  String amount,
  String invoice,
) async {
  Links link = Links();

  final Map<String, dynamic> jsonData = {
    "payment_id": id,
    "tenant_id": tenantId,
    "amount": amount,
    "invoice": invoice,
  };

  final Map<String, String> queryParams = {
    "operation": "updatePayment",
    "json": jsonEncode(jsonData),
  };

  try {
    final response = await http.post(
      Uri.parse(link.admin_link).replace(queryParameters: queryParams),
    );

    print(queryParams);

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);

      if (res == "0") {
        print("Something went wrong");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update payment")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment updated successfully!")),
        );
        getPayments();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating payment")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while updating payment")),
    );
  }
}

Future<void> deletePayment(BuildContext context, String paymentId) async {
  Links link = Links();

  final Map<String, String> queryParams = {
    "operation": "deletePayment",
    "json": jsonEncode({"id": paymentId}),
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
        ).showSnackBar(SnackBar(content: Text("Failed to delete payment")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment deleted successfully!")),
        );
        getPayments();
      }
    } else {
      print("Server Error: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting payment")));
    }
  } catch (error) {
    print("Runtime Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error while deleting payment")),
    );
  }
}
