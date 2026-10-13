class FavoritePlace {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;

  const FavoritePlace({
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

  factory FavoritePlace.fromJson(
    Map<String, dynamic> json,
  ) {
    return FavoritePlace(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude:
          (json['latitude'] as num).toDouble(),
      longitude:
          (json['longitude'] as num).toDouble(),
      category:
          json['category'] as String,
    );
  }
}