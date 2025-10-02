class Vehicle {
  final int id;
  final String plate;
  final String type;

  Vehicle({required this.id, required this.plate, required this.type});

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'],
    plate: json['plate'],
    type: json['type'],
  );
}
