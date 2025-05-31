import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modules/customers/models/customer.dart';

class CustomersService {
  final String baseUrl = 'https://kqgbftwsodpttpqgqnbh.supabase.co/rest/v1';
  final String apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZ2JmdHdzb2RwdHRwcWdxbmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODk5OTksImV4cCI6MjA2MTU2NTk5OX0.rwJSY4bJaNdB8jDn3YJJu_gKtznzm-dUKQb4OvRtP6c';
  final List<Customer> _customers = [];

  Future<List<Customer>> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers'),
        headers: {
          'apikey': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _customers.clear();
        _customers.addAll(data.map((json) => Customer.fromJson(json)));
        return _customers;
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchCustomers: $e');
      throw Exception('Failed to load customers: $e');
    }
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere(
        (customer) => customer.id.toString() == id,
      );
    } catch (e) {
      return null;
    }
  }
}
