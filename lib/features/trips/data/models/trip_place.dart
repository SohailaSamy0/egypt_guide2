class TripPlace {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;

  const TripPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
    };
  }

  factory TripPlace.fromJson(
    Map<String, dynamic> json,
  ) {
    return TripPlace(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      latitude:
          (json['latitude'] as num?)
                  ?.toDouble() ??
              0,
      longitude:
          (json['longitude'] as num?)
                  ?.toDouble() ??
              0,
      category:
          json['category']?.toString() ??
              'Place',
    );
  }
}