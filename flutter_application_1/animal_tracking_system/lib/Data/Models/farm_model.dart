class FarmModel {
  final String id;
  final String name;
  final String ownerId;
  final String location;
  final double latitude;
  final double longitude;
  final int capacity;
  final int currentAnimals;
  final String status;
  final DateTime createdAt;
  final String imageUrl;
  final bool isVerified;

  FarmModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.currentAnimals,
    required this.status,
    required this.createdAt,
    required this.imageUrl,
    required this.isVerified,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'],
      name: json['name'],
      ownerId: json['owner_id'],
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      capacity: json['capacity'],
      currentAnimals: json['current_animals'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'current_animals': currentAnimals,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
      'is_verified': isVerified,
    };
  }
}