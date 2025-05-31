import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupabaseService {
  static final String baseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String apiKey = dotenv.env['SUPABASE_API_KEY'] ?? '';

  static Map<String, String> get _headers => {
    'apikey': apiKey,
    'Content-Type': 'application/json',
  };

  // Customers
  static Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load customers');
  }

  // Activities
  static Future<List<Map<String, dynamic>>> getActivities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/activities'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load activities');
  }

  // Visits
  static Future<List<Map<String, dynamic>>> getVisits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/visits'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load visits');
  }

  static Future<Map<String, dynamic>> createVisit(Map<String, dynamic> visit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visits'),
      headers: _headers,
      body: json.encode(visit),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create visit');
  }

  static Future<Map<String, dynamic>> updateVisit(int id, Map<String, dynamic> visit) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/visits?id=eq.$id'),
      headers: _headers,
      body: json.encode(visit),
    );
    if (response.statusCode == 204) {
      return visit;
    }
    throw Exception('Failed to update visit');
  }
} 