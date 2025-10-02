import 'package:flutter/material.dart';
import 'package:flutter_shm_client/screens/sensor_detail_screen.dart';
import 'package:flutter_shm_client/services/rest_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  String formatDateReadable(String isoDate) {
    try {
      final parsed = DateTime.parse(isoDate);
      return DateFormat('EEEE, MMM d, yyyy – HH:mm').format(parsed);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget buildSensorCard(BuildContext context, Map<String, dynamic> device) {
    final imagePath = device['image_path'] ?? '';
    final broker = device['broker'] ?? {};
    final host = dotenv.env['host'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SensorDetailScreen(device: device)),
        );
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath.isNotEmpty)
              Image.network(
                '$host$imagePath',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device['device_name'] ?? 'Unnamed Sensor',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Device ID: ${device['device_id'] ?? '—'}'),
                  Text('Status: ${device['device_status'] ?? '—'}'),
                  const SizedBox(height: 8),
                  Text(
                    'Broker: ${broker['device_name'] ?? '—'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: RestService.fetchDataDevice(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error cannot load data'));
          }

          final endDevices = snapshot.data!['end_devices'] as List;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Sensor List',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...endDevices.map((e) => buildSensorCard(context, e)),
            ],
          );
        },
      ),
    );
  }
}
