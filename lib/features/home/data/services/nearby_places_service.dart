import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:egypt_guide/features/home/data/models/nearby_place.dart';

class NearbyPlacesService {
  Future<List<NearbyPlace>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required String category,
    int radius = 3000,
  }) async {
    final tag = _categoryTag(category);

    final query = '''
[out:json][timeout:20];
(
  node(around:$radius,$latitude,$longitude)$tag;
  way(around:$radius,$latitude,$longitude)$tag;
  relation(around:$radius,$latitude,$longitude)$tag;
);
out center;
''';

    final response = await http.post(
      Uri.parse(
        'https://overpass-api.de/api/interpreter',
      ),
      body: {
        'data': query,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Could not load nearby places.',
      );
    }

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final elements =
        data['elements'] as List<dynamic>;

    final List<NearbyPlace> places = [];

    for (final element in elements) {
      final map = element as Map<String, dynamic>;

      final tags =
          map['tags'] as Map<String, dynamic>?;

      final center =
          map['center'] as Map<String, dynamic>?;

      final lat = map['lat'] ?? center?['lat'];
      final lon = map['lon'] ?? center?['lon'];

      if (lat == null || lon == null) {
        continue;
      }

      final name =
          tags?['name']?.toString() ??
          tags?['name:en']?.toString();

      if (name == null || name.trim().isEmpty) {
        continue;
      }

      places.add(
        NearbyPlace(
          id: map['id'] as int,
          name: name,
          latitude: (lat as num).toDouble(),
          longitude: (lon as num).toDouble(),
          category: category,
        ),
      );
    }

    return places.take(30).toList();
  }

  String _categoryTag(String category) {
    switch (category) {
      case 'Restaurants':
        return '["amenity"="restaurant"]';

      case 'Cafes':
        return '["amenity"="cafe"]';

      case 'Museums':
        return '["tourism"="museum"]';

      case 'Attractions':
        return '["tourism"="attraction"]';

      case 'Hotels':
        return '["tourism"="hotel"]';

      default:
        return '["tourism"="attraction"]';
    }
  }
}