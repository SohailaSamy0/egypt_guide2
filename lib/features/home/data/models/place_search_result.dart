class PlaceSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;
  final String category;
  final String type;

  const PlaceSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.type,
  });

  factory PlaceSearchResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return PlaceSearchResult(
      displayName:
          json['display_name']?.toString() ?? 'Unknown place',
      latitude:
          double.tryParse(json['lat']?.toString() ?? '') ?? 0,
      longitude:
          double.tryParse(json['lon']?.toString() ?? '') ?? 0,
      category:
          json['category']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}