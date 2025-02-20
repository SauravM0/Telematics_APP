import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';

class RoutingService {
  // Get your API key from https://openrouteservice.org/
  static const String _apiKey = 'API'; // Free API key for testing
  static const String _baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?api_key=$_apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}',
        ),
        headers: {
          'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['features'][0]['geometry']['coordinates'] as List;
        
        return coordinates
            .map((coord) => LatLng(coord[1] as double, coord[0] as double))
            .toList();
      }
      throw Exception('Failed to get route: ${response.statusCode}');
    } catch (e) {
      print('Error getting route: $e');
      // Return direct line between points as fallback
      return [start, end];
    }
  }
} 
