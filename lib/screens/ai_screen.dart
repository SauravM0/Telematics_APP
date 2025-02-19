import 'package:flutter/material.dart';

class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'AI Assistant',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            'Vehicle Diagnostics',
            'Get AI-powered insights about your vehicle\'s health',
            Icons.analytics_outlined,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Driving Analysis',
            'View your driving patterns and get personalized tips',
            Icons.auto_graph,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Maintenance Predictions',
            'AI predictions for upcoming maintenance needs',
            Icons.build_outlined,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Route Optimization',
            'Get AI-suggested optimal routes based on traffic',
            Icons.route_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}