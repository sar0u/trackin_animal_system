class FraudReportModel {
  final String id;
  final String reporterId;
  final String type;
  final String description;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String location;
  final List<String> imageUrls;
  final String status;
  final DateTime createdAt;

  FraudReportModel({
    required this.id,
    required this.reporterId,
    required this.type,
    required this.description,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
  });

  factory FraudReportModel.fromJson(Map<String, dynamic> json) {
    return FraudReportModel(
      id: json['id'],
      reporterId: json['reporter_id'],
      type: json['type'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      location: json['location'],
      imageUrls: List<String>.from(json['image_urls']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'image_urls': imageUrls,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}