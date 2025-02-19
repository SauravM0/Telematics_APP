import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RouteInstructions extends StatelessWidget {
  final List<LatLng> route;
  final VoidCallback onClose;

  const RouteInstructions({
    super.key,
    required this.route,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Route Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildInstruction(
                      'Start',
                      'Head north on Main Street',
                      Icons.arrow_upward,
                    ),
                    _buildInstruction(
                      'After 200m',
                      'Turn right onto Oak Avenue',
                      Icons.turn_right,
                    ),
                    _buildInstruction(
                      'After 400m',
                      'Continue straight',
                      Icons.straight,
                    ),
                    _buildInstruction(
                      'Destination',
                      'Arrive at your destination',
                      Icons.location_on,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstruction(String distance, String instruction, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(instruction),
      subtitle: Text(distance),
    );
  }
} 