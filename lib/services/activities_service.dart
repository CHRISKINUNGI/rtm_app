import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivitiesService {
  final String baseUrl = 'https://kqgbftwsodpttpqgqnbh.supabase.co/rest/v1';
  final String apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZ2JmdHdzb2RwdHRwcWdxbmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODk5OTksImV4cCI6MjA2MTU2NTk5OX0.rwJSY4bJaNdB8jDn3YJJu_gKtznzm-dUKQb4OvRtP6c';

  Future<List<Map<String, dynamic>>> fetchActivities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities'),
        headers: {
          'apikey': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchActivities: $e');
      throw Exception('Failed to load activities: $e');
    }
  }
}
