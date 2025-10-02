import 'package:flutter/material.dart';
import 'package:flutter_shm_client/services/rest_service.dart';
import 'package:intl/intl.dart';

class BrokerScreen extends StatefulWidget {
  const BrokerScreen({super.key});

  @override
  State<BrokerScreen> createState() => _BrokerScreenState();
}

class _BrokerScreenState extends State<BrokerScreen> {
  late Future<List<dynamic>> brokerData;

  @override
  void initState() {
    super.initState();
    brokerData = RestService.fetchBrokerConnection();
  }

  String formatTimestamp(String? iso) {
    if (iso == null || iso.isEmpty) return 'N/A';
    final dt = DateTime.tryParse(iso);
    return dt != null ? DateFormat('yyyy-MM-dd HH:mm').format(dt) : 'Invalid';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: brokerData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No broker data available'));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final status = item['status'] ?? 'Unknown';
              final sensorType = item['sensor_type'] ?? 'N/A';
              final deviceName = item['device_name'] ?? 'Unnamed';
              final updated = formatTimestamp(item['updated_at']);
              final urlPath = item['url_path'] ?? 'N/A';

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sensors,
                        color: status == 'online' ? Colors.green : Colors.red,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deviceName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Sensor Type: $sensorType'),
                            Text('Status: $status'),
                            Text('Updated: $updated'),
                            const SizedBox(height: 4),
                            Text(
                              'URL Path:',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              urlPath,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Optional trailing icon
                      // const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
