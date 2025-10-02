import 'package:flutter/material.dart';
import 'package:flutter_shm_client/screens/broker_screen.dart';
import 'package:flutter_shm_client/screens/home_screen.dart';
import 'package:flutter_shm_client/screens/login_screen.dart';
import 'package:flutter_shm_client/screens/sensors_screen.dart';
import 'package:flutter_shm_client/screens/vehicle_screen.dart';
import 'package:flutter_shm_client/services/websocket_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final screens = [
    const HomeScreen(),
    const SensorsScreen(),
    const VehicleScreen(),
    const BrokerScreen()
  ];

  final WebSocketService ws = WebSocketService();
  bool connected = false;
  String lastMessage = 'Waiting for data...';

  void connectWebSocket() {
    ws.connect(
      onMessage: (msg) {
        setState(() => lastMessage = msg);
      },
      onStatus: (status) {
        setState(() => connected = status);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  @override
  void dispose() {
    ws.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHM-App'),
        actions: [
          Row(
            children: [
              Icon(
                connected ? Icons.cloud_done : Icons.cloud_off,
                color: connected ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(
                connected ? 'Online' : 'Offline',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              if (!connected)
                IconButton(
                  tooltip: 'Reconnect',
                  icon: const Icon(Icons.refresh),
                  onPressed: connectWebSocket,
                ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (value) {
                  switch (value) {
                    case 'login':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      break;
                    case 'logout':
                      // logout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'login', child: Text('Login')),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
              ),
            ],
          ),
        ],
      ),

      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.sensors), label: "Sensors"),
          NavigationDestination(
            icon: Icon(Icons.directions_car),
            label: "Vehicles",
          ),
          NavigationDestination(icon: Icon(Icons.connecting_airports), label: "Brokers")
        ],
      ),
    );
  }
}
