class AnimalEntity {
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

  AnimalEntity({
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
}