class ConstatRequest {
  final int farmId;
  final int? controlSessionId;
  final String type;
  final String description;
  final double? latitude;
  final double? longitude;
  final String? localisationText;
  final String? photoUrl;
  final String? voiceMemoUrl;

  ConstatRequest({
    required this.farmId,
    this.controlSessionId,
    required this.type,
    required this.description,
    this.latitude,
    this.longitude,
    this.localisationText,
    this.photoUrl,
    this.voiceMemoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "farmId": farmId,
      "controlSessionId": controlSessionId,
      "type": type,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "localisationText": localisationText,
      "photoUrl": photoUrl,
      "voiceMemoUrl": voiceMemoUrl,
    };
  }
}