class Sensor {
  final int id;
  final String name;
  final String location;
  final double value;

  Sensor({required this.id, required this.name, required this.location, required this.value});

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
    id: json['id'],
    name: json['name'],
    location: json['location'],
    value: json['value'].toDouble(),
  );
}
