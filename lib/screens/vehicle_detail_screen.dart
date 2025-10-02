import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../services/rest_service.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VehicleDetailScreen extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;

  const VehicleDetailScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late MapController mapController;
  late Future<Map<String, dynamic>> vehicleFuture;

  @override
  void initState() {
    super.initState();
    vehicleFuture = RestService.fetchDataByVehicleId(widget.vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    final host = dotenv.env['host'];

    return Scaffold(
      appBar: AppBar(title: Text(widget.vehicleName)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: vehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error cannot load data'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No vehicle data found'));
          }

          final vehicle = snapshot.data!;
          final lat = vehicle['latitude'] ?? 41.0;
          final lng = vehicle['longitude'] ?? 28.8;
          final imagePath = vehicle['image_path'];
          final devices = vehicle['end_devices'] ?? [];

          mapController = MapController(
            initPosition: GeoPoint(latitude: lat, longitude: lng),
          );

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await mapController.addMarker(
              GeoPoint(latitude: lat, longitude: lng),
              markerIcon: const MarkerIcon(
                icon: Icon(Icons.location_on, color: Colors.blue, size: 48),
              ),
            );

            for (final device in devices) {
              final data = device['last_data'];
              if (data?['latitude'] != null && data?['longitude'] != null) {
                await mapController.addMarker(
                  GeoPoint(
                    latitude: data['latitude'],
                    longitude: data['longitude'],
                  ),
                  markerIcon: const MarkerIcon(
                    icon: Icon(Icons.sensors, color: Colors.green, size: 40),
                  ),
                );
              }
            }
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '$host$imagePath',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                vehicle['name'] ?? 'Unnamed Vehicle',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Devices: ${devices.length}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    OSMFlutter(
                      controller: mapController,
                      osmOption: OSMOption(
                        zoomOption: ZoomOption(initZoom: 15),
                        roadConfiguration: RoadOption(roadColor: Colors.orange),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'zoomIn',
                            mini: true,
                            onPressed: () async {
                              await mapController.zoomIn();
                            },
                            child: const Icon(Icons.zoom_in),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'zoomOut',
                            mini: true,
                            onPressed: () async {
                              await mapController.zoomOut();
                            },
                            child: const Icon(Icons.zoom_out),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),
              ...devices.map((device) => DeviceCard(device)).toList(),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}

class DeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;

  const DeviceCard(this.device, {super.key});

  @override
  Widget build(BuildContext context) {
    final lastData = device['last_data'] ?? {};
    final imagePath = device['image_path'];
    final status = device['device_status'] ?? 'unknown';
    final sensorType = lastData['sensor_type'] ?? 'Unknown';
    final lat = lastData['latitude']?.toStringAsFixed(6) ?? 'N/A';
    final lng = lastData['longitude']?.toStringAsFixed(6) ?? 'N/A';
    final host = dotenv.env['host'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device['device_name'] ?? 'Unnamed Device',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '$host$imagePath',
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            color: status == 'online'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Text('Sensor Type: $sensorType'),
                    Text('Location: $lat, $lng'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
