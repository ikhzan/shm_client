import 'package:flutter/material.dart';
import 'package:flutter_shm_client/services/rest_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildSensorCard(Map<String, dynamic> sensor) {
    final sensorData = sensor['sensor_data'] ?? {};
    final flags = sensorData['status_flags'] ?? {};
    final raw = sensor['raw_payload'] ?? {};
    final ids = raw['end_device_ids'] ?? {};
    final uplink = raw['uplink_message'] ?? {};
    final timestamp = sensor['timestamp'] ?? '';
    final formattedTime = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(DateTime.parse(timestamp));
    final formattedReceivedAt = formatDateReadable(
      sensor['raw_payload']['received_at'],
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sensor['device_id']} • ${sensor['sensor_type']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Timestamp: $formattedTime',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile(
                  'Battery',
                  '${sensorData['battery_percent']}%',
                  Icons.battery_full,
                ),
                _infoTile(
                  'Strain',
                  '${sensorData['strain_microstrain']} µε',
                  Icons.speed,
                ),
                _infoTile(
                  'Temp',
                  '${sensorData['temperature_celsius']} °C',
                  Icons.thermostat,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusFlag('GPS Fix', flags['gps_fix']),
                _statusFlag('Sensor OK', flags['sensor_ok']),
                _statusFlag('Low Battery', flags['low_battery']),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Raw Payload',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Received At: $formattedReceivedAt'),
            Text('Device EUI: ${ids['dev_eui'] ?? '—'}'),
            Text('Frequency: ${uplink['settings']?['frequency'] ?? '—'} Hz'),
          ],
        ),
      ),
    );
  }

  String formatDateReadable(String isoDate) {
    try {
      final parsed = DateTime.parse(isoDate);
      return DateFormat('EEEE, MMM d, yyyy – HH:mm').format(parsed);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _statusFlag(String label, bool? status) {
    final color = status == true ? Colors.green : Colors.red;
    final icon = status == true ? Icons.check_circle : Icons.cancel;
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: RestService.fetchDataSensor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final fatigueData = snapshot.data!['fatigue_data'] as List;
          final humidityData = snapshot.data!['humidity_data'] as List;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Fatigue Sensors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...fatigueData.map((e) => buildSensorCard(e)),
              const SizedBox(height: 24),
              const Text(
                'Humidity Sensors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...humidityData.map((e) => buildSensorCard(e)),
            ],
          );
        },
      ),
    );
  }
}
