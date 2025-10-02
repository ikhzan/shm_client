import 'package:flutter/material.dart';
import 'package:flutter_shm_client/screens/sensor_detail_screen.dart';
import 'package:flutter_shm_client/screens/vehicle_detail_screen.dart';
import 'package:flutter_shm_client/services/rest_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  Widget buildVehicleCard(BuildContext context, Map<String, dynamic> vehicle) {
    final imagePath = vehicle['image_path'] ?? '';
    final sensors = List<Map<String, dynamic>>.from(
      vehicle['end_devices'] ?? [],
    );
    final vehicleID = vehicle['id'];
    final host = dotenv.env['host'];
    return Card(
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
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Text(
                    vehicle['name'] ?? 'Unnamed Vehicle',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        
                        builder: (_) => VehicleDetailScreen(vehicleId: vehicleID, vehicleName: vehicle['name'],),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),
                const Text(
                  'Linked Sensors:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ...sensors.map(
                  (sensor) => ListTile(
                    leading: Image.network(
                      '$host${sensor['image_path'] ?? ''}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.sensors),
                    ),
                    title: Text(sensor['device_name'] ?? 'Unnamed Sensor'),
                    subtitle: Text('Status: ${sensor['device_status'] ?? '—'}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SensorDetailScreen(device: sensor),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUnlinkedSensorTile(Map<String, dynamic> sensor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.sensors),
        title: Text(sensor['device_name'] ?? 'Unlinked Sensor'),
        subtitle: Text('Sensor ID: ${sensor['device_id'] ?? '—'}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: RestService.fetchVehicle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final vehicles = List<Map<String, dynamic>>.from(
            snapshot.data!['vehicles'],
          );
          final unlinkedSensors = List<Map<String, dynamic>>.from(
            snapshot.data!['unlinked_sensors'],
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              ...vehicles.map((v) => buildVehicleCard(context, v)),
              const SizedBox(height: 24),
              const Text(
                'Unlinked Sensors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...unlinkedSensors.map((s) => buildUnlinkedSensorTile(s)),
            ],
          );
        },
      ),
    );
  }
}
