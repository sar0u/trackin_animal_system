class AnimalModel {
  final String id;
  final String name;
  final String breed;
  final double age;
  final double weight;
  final String status;
  final String farmId;
  final String rfid;
  final DateTime birthDate;
  final DateTime lastHealthCheck;
  final String imageUrl;
  final bool isVerified;

  AnimalModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.weight,
    required this.status,
    required this.farmId,
    required this.rfid,
    required this.birthDate,
    required this.lastHealthCheck,
    required this.imageUrl,
    required this.isVerified,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'],
      name: json['name'],
      breed: json['breed'],
      age: json['age'].toDouble(),
      weight: json['weight'].toDouble(),
      status: json['status'],
      farmId: json['farm_id'],
      rfid: json['rfid'],
      birthDate: DateTime.parse(json['birth_date']),
      lastHealthCheck: DateTime.parse(json['last_health_check']),
      imageUrl: json['image_url'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'weight': weight,
      'status': status,
      'farm_id': farmId,
      'rfid': rfid,
      'birth_date': birthDate.toIso8601String(),
      'last_health_check': lastHealthCheck.toIso8601String(),
      'image_url': imageUrl,
      'is_verified': isVerified,
    };
  }
}