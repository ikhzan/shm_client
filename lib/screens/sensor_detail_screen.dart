import 'package:flutter/material.dart';
import 'package:flutter_shm_client/services/rest_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_shm_client/widgets/render_fatigue_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SensorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> device;

  const SensorDetailScreen({super.key, required this.device});

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  late Future<Map<String, dynamic>> sensorDetailFuture;

  @override
  void initState() {
    super.initState();
    sensorDetailFuture = RestService.fetchDataByDeviceId(
      widget.device['device_id'],
    );
  }

  Widget buildChart(List<dynamic> sensorData) {
    final strainSpots = sensorData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final rawStrain = entry.value['strain_microstrain'];
      final strain = rawStrain is num ? rawStrain.toDouble() : 0.0;
      return FlSpot(index, strain);
    }).toList();

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: strainSpots,
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
          ),
        ],
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.device['image_path'] ?? '';
    final host = dotenv.env['host'];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device['device_name'] ?? 'Sensor Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: sensorDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // final sensorData = snapshot.data!['sensor_data'] as List;
          final sensorData = List<Map<String, dynamic>>.from(
            snapshot.data!['sensor_data'],
          );
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (imagePath.isNotEmpty)
                Image.network(
                  '$host$imagePath',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              Text(
                'Device ID: ${widget.device['device_id'] ?? '—'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Status: ${widget.device['device_status'] ?? '—'}'),
              const Divider(height: 24),
              const Text(
                'Strain History',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: LineChart(
                    LineChartData(),
                  ), // Placeholder or actual chart
                ),
              ),

              if (sensorData.isNotEmpty)
                SizedBox(height: 250, child: renderFatigueChart(sensorData)),
              if (sensorData.isEmpty) const Text('No sensor data available'),
            ],
          );
        },
      ),
    );
  }
}
