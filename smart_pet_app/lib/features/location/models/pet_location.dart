class PetLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  final double? speed;
  final double? heading;

  PetLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    this.speed,
    this.heading,
  });

  // Convert from Geolocator Position
  factory PetLocation.fromPosition(dynamic position) {
    return PetLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp ?? DateTime.now(),
      speed: position.speed,
      heading: position.heading,
    );
  }

  // Convert to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'heading': heading,
    };
  }

  // Create from JSON (from backend)
  factory PetLocation.fromJson(Map<String, dynamic> json) {
    return PetLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy: json['accuracy'],
      timestamp: DateTime.parse(json['timestamp']),
      speed: json['speed'],
      heading: json['heading'],
    );
  }

  @override
  String toString() {
    return 'PetLocation(lat: $latitude, lng: $longitude, time: $timestamp)';
  }
}
