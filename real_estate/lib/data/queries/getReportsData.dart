import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_estate/util/links.dart';

Future<List<dynamic>?> getBalancesReport() async {
  Links link = Links();

  final query = {"operation": "getBalancesReport", "json": jsonEncode([])};

  try {
    final response = await http.get(
      Uri.parse(link.admin_link).replace(queryParameters: query),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      print("Balances Report Data: $res");
      if (res is List<dynamic>) {
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

Future<Map<String, dynamic>?> getMonthlyReports() async {
  Links link = Links();

  final query = {"operation": "getMonthlyReports", "json": jsonEncode([])};

  try {
    final response = await http.get(
      Uri.parse(link.admin_link).replace(queryParameters: query),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      print("Balances Report Data: $res");
      if (res is Map<String, dynamic>) {
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
