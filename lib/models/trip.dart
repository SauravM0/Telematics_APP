import 'package:latlong2/latlong.dart';

class Trip {
  final String id;
  final List<LatLng> route;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic> diagnosticData;

  Trip({
    required this.id,
    required this.route,
    required this.startTime,
    required this.endTime,
    required this.diagnosticData,
  });
} 