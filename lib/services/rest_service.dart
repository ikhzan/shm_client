import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/sensor.dart';
import '../data/vehicle.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RestService {
  static final _baseUrl = "${dotenv.env['host']}/api";

  static Future<List<Sensor>> fetchSensors() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/sensors'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Sensor.fromJson(e)).toList();
  }

  static Future<List<Vehicle>> fetchVehicles() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/vehicles'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Vehicle.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> fetchDataSensor() async {
    final response = await http.get(Uri.parse('$_baseUrl/all'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'fatigue_data': data['fatigue_data'] ?? [],
        'humidity_data': data['humidity_data'] ?? [],
      };
    } else {
      throw Exception('Failed to fetch sensor data');
    }
  }

  static Future<Map<String, dynamic>> fetchDataDevice() async {
    final response = await http.get(Uri.parse('$_baseUrl/all_enddevice'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'end_devices': data['end_devices'] ?? [],
        'unattached_brokers': data['unattached_brokers'] ?? [],
      };
    } else {
      throw Exception('Failed to fetch end device data');
    }
  }

  static Future<Map<String, dynamic>> fetchDataByDeviceId(
    String deviceId,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/detail_sensor',
    ).replace(queryParameters: {'sensor_id': deviceId});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return {
        'end_devices': data['end_devices'] ?? [],
        'sensor_data': data['sensor_data'] ?? [],
      };
    } else {
      throw Exception('Failed to fetch sensor detail');
    }
  }

  static Future<Map<String, dynamic>> fetchVehicle() async {
    final response = await http.get(Uri.parse('$_baseUrl/all_vehicle'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'vehicles': data['vehicles'] ?? [],
        'unlinked_sensors': data['unlinked_sensors'] ?? [],
      };
    } else {
      throw Exception('Failed to fetch vehicle data');
    }
  }

  static Future<List<dynamic>> fetchBrokerConnection() async {
    final response = await http.get(Uri.parse('$_baseUrl/read_broker'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    } else {
      throw Exception('Failed to load broker data');
    }
  }

  static Future<Map<String, dynamic>> fetchDataByVehicleId(
    int vehicleId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/detail_vehicle',
      ).replace(queryParameters: {'id': vehicleId.toString()}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        print("vehicle detail $data");
        return data.first as Map<String, dynamic>;
      } else {
        throw Exception('No vehicle data found');
      }
    } else {
      throw Exception('Failed to load vehicle data');
    }
  }
}
