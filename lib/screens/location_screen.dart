import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/location_search.dart';
import '../services/routing_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  List<LatLng> _routePoints = [];
  bool _isTracking = false;
  LatLng? _startPoint;
  LatLng? _endPoint;
  List<List<LatLng>> _previousRoutes = [];
  List<LatLng> _directionsRoute = [];
  String _routeDistance = '';
  String _routeDuration = '';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadPreviousRoutes();
  }

  Future<void> _loadPreviousRoutes() async {
    // TODO: Load from local storage or Firebase
    setState(() {
      _previousRoutes = [];
    });
  }

  Future<void> _searchLocation() async {
    final result = await showSearch(
      context: context,
      delegate: LocationSearchDelegate(),
    );

    if (result != null) {
      if (_startPoint == null) {
        setState(() {
          _startPoint = result;
        });
      } else {
        setState(() {
          _endPoint = result;
        });
        _calculateRoute();
      }
    }
  }

  Future<void> _calculateRoute() async {
    if (_startPoint == null || _endPoint == null) return;

    try {
      final route = await RoutingService.getRoute(_startPoint!, _endPoint!);

      setState(() {
        _routePoints = route;
        _mapController.fitBounds(
          LatLngBounds.fromPoints(route),
          options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
        );
      });
    } catch (e) {
      print('Error calculating route: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      setState(() {
        _currentPosition = position;
        _routePoints.add(LatLng(position.latitude, position.longitude));

        if (_isTracking) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            _mapController.zoom,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Vehicle Location',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: _searchLocation,
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () {
              _showPreviousRoutes();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_startPoint != null || _endPoint != null) _buildRouteDetails(),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition != null
                    ? LatLng(
                        _currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(0, 0),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    if (_routePoints.isNotEmpty)
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 4.0,
                        isDotted: false,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    if (_startPoint != null)
                      Marker(
                        point: _startPoint!,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                    if (_endPoint != null)
                      Marker(
                        point: _endPoint!,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Current Location'),
                  subtitle: _currentPosition != null
                      ? Text(
                          'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}\n'
                          'Long: ${_currentPosition!.longitude.toStringAsFixed(4)}')
                      : const Text('Waiting for location...'),
                  trailing: IconButton(
                    icon: Icon(
                      _isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                      color: _isTracking ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isTracking = !_isTracking;
                        if (_isTracking && _currentPosition != null) {
                          _mapController.move(
                            LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            _mapController.zoom,
                          );
                        }
                      });
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Travel History'),
                  subtitle: Text('${_routePoints.length} points recorded'),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _routePoints.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route to Destination',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_routeDistance.isNotEmpty && _routeDuration.isNotEmpty)
                      Text(
                        '$_routeDistance • $_routeDuration',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.directions),
                onPressed: _startNavigation,
              ),
            ],
          ),
          if (_startPoint != null && _endPoint != null)
            Column(
              children: [
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: const Text('Start'),
                  subtitle: FutureBuilder<String>(
                    future: _getAddressFromLatLng(_startPoint!),
                    builder: (context, snapshot) {
                      return Text(snapshot.data ?? 'Loading...');
                    },
                  ),
                ),
                const Icon(Icons.more_vert),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: const Text('Destination'),
                  subtitle: FutureBuilder<String>(
                    future: _getAddressFromLatLng(_endPoint!),
                    builder: (context, snapshot) {
                      return Text(snapshot.data ?? 'Loading...');
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.postalCode}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return '${position.latitude}, ${position.longitude}';
  }

  void _startNavigation() {
    // Implement turn-by-turn navigation here
    // For now, just center the map on the route
    if (_routePoints.isNotEmpty) {
      _mapController.fitBounds(
        LatLngBounds.fromPoints(_routePoints),
        options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
      );
    }
  }

  void _showPreviousRoutes() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Previous Routes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_previousRoutes.isEmpty)
              const Text('No previous routes')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _previousRoutes.length,
                  itemBuilder: (context, index) {
                    final route = _previousRoutes[index];
                    return ListTile(
                      title: Text('Route ${index + 1}'),
                      subtitle: Text(
                        '${route.first.latitude}, ${route.first.longitude} to '
                        '${route.last.latitude}, ${route.last.longitude}',
                      ),
                      onTap: () {
                        setState(() {
                          _routePoints = route;
                          _mapController.fitBounds(
                            LatLngBounds.fromPoints(route),
                            options: const FitBoundsOptions(
                                padding: EdgeInsets.all(50)),
                          );
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
