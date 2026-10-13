import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:egypt_guide/features/home/data/models/nearby_place.dart';

class RecommendationService {
  static const String _endpoint =
      'https://overpass-api.de/api/interpreter';

  Future<List<NearbyPlace>> getRecommendations({
    required double latitude,
    required double longitude,
    required List<String> interests,
    int radiusMeters = 7000,
  }) async {
    if (interests.isEmpty) {
      return [];
    }

    final queryParts = <String>[];

    for (final interest in interests) {
      queryParts.addAll(
        _queriesForInterest(
          interest: interest,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
      );
    }

    if (queryParts.isEmpty) {
      return [];
    }

    final query = '''
[out:json][timeout:25];
(
${queryParts.join('\n')}
);
out center tags;
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      body: {
        'data': query,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Recommendation request failed: ${response.statusCode}',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final elements =
        data['elements']
                as List<dynamic>? ??
            [];

    final origin =
        LatLng(
      latitude,
      longitude,
    );

    final distance = Distance();

    final Map<int, NearbyPlace>
        uniquePlaces = {};

    for (final raw in elements) {
      final element =
          raw as Map<String, dynamic>;

      final tags =
          (element['tags']
                  as Map<String, dynamic>?) ??
              {};

      final name =
          tags['name:en']
                  ?.toString()
                  .trim() ??
              tags['name']
                  ?.toString()
                  .trim() ??
              tags['name:ar']
                  ?.toString()
                  .trim();

      if (name == null ||
          name.isEmpty) {
        continue;
      }

      double? lat;
      double? lon;

      if (element['lat'] != null &&
          element['lon'] != null) {
        lat =
            (element['lat'] as num)
                .toDouble();

        lon =
            (element['lon'] as num)
                .toDouble();
      } else {
        final center =
            element['center']
                as Map<String, dynamic>?;

        if (center != null &&
            center['lat'] != null &&
            center['lon'] != null) {
          lat =
              (center['lat'] as num)
                  .toDouble();

          lon =
              (center['lon'] as num)
                  .toDouble();
        }
      }

      if (lat == null ||
          lon == null) {
        continue;
      }

      final osmId =
          (element['id'] as num)
              .toInt();

      final osmType =
          element['type']
                  ?.toString() ??
              'node';

      final id =
          _stableId(
        osmId,
        osmType,
      );

      final category =
          _detectInterest(
        tags,
        interests,
      );

      uniquePlaces[id] =
          NearbyPlace(
        id: id,
        name: name,
        latitude: lat,
        longitude: lon,
        category: category,
      );
    }

    final places =
        uniquePlaces.values.toList();

    places.sort(
      (a, b) {
        final aDistance =
            distance.as(
          LengthUnit.Meter,
          origin,
          LatLng(
            a.latitude,
            a.longitude,
          ),
        );

        final bDistance =
            distance.as(
          LengthUnit.Meter,
          origin,
          LatLng(
            b.latitude,
            b.longitude,
          ),
        );

        return aDistance.compareTo(
          bDistance,
        );
      },
    );

    return places.take(30).toList();
  }

  List<String> _queriesForInterest({
    required String interest,
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) {
    String q(
      String tag,
    ) {
      return '''
node(around:$radiusMeters,$latitude,$longitude)$tag;
way(around:$radiusMeters,$latitude,$longitude)$tag;
relation(around:$radiusMeters,$latitude,$longitude)$tag;
''';
    }

    switch (interest) {
      case 'history':
        return [
          q('["historic"]'),
        ];

      case 'museums':
        return [
          q(
            '["tourism"="museum"]',
          ),
        ];

      case 'food':
        return [
          q(
            '["amenity"="restaurant"]',
          ),
          q(
            '["amenity"="cafe"]',
          ),
        ];

      case 'beaches':
        return [
          q(
            '["natural"="beach"]',
          ),
        ];

      case 'shopping':
        return [
          q('["shop"]'),
          q(
            '["shop"="mall"]',
          ),
        ];

      case 'adventure':
        return [
          q(
            '["leisure"="sports_centre"]',
          ),
          q('["sport"]'),
        ];

      case 'ancient_egypt':
        return [
          q(
            '["historic"="archaeological_site"]',
          ),
          q(
            '["historic"="tomb"]',
          ),
          q(
            '["historic"="monument"]',
          ),
        ];

      case 'culture':
        return [
          q(
            '["amenity"="arts_centre"]',
          ),
          q(
            '["tourism"="gallery"]',
          ),
          q(
            '["amenity"="theatre"]',
          ),
        ];

      case 'nature':
        return [
          q(
            '["leisure"="park"]',
          ),
          q(
            '["leisure"="garden"]',
          ),
          q(
            '["leisure"="nature_reserve"]',
          ),
        ];

      case 'nightlife':
        return [
          q(
            '["amenity"="nightclub"]',
          ),
          q(
            '["amenity"="bar"]',
          ),
          q(
            '["amenity"="pub"]',
          ),
        ];

      default:
        return [];
    }
  }

  String _detectInterest(
    Map<String, dynamic> tags,
    List<String> interests,
  ) {
    bool selected(
      String key,
    ) =>
        interests.contains(key);

    if (selected('museums') &&
        tags['tourism'] ==
            'museum') {
      return 'museums';
    }

    if (selected('food') &&
        (tags['amenity'] ==
                'restaurant' ||
            tags['amenity'] ==
                'cafe')) {
      return 'food';
    }

    if (selected('beaches') &&
        tags['natural'] ==
            'beach') {
      return 'beaches';
    }

    if (selected('ancient_egypt') &&
        (tags['historic'] ==
                'archaeological_site' ||
            tags['historic'] ==
                'tomb' ||
            tags['historic'] ==
                'monument')) {
      return 'ancient_egypt';
    }

    if (selected('culture') &&
        (tags['amenity'] ==
                'arts_centre' ||
            tags['amenity'] ==
                'theatre' ||
            tags['tourism'] ==
                'gallery')) {
      return 'culture';
    }

    if (selected('nightlife') &&
        (tags['amenity'] ==
                'nightclub' ||
            tags['amenity'] ==
                'bar' ||
            tags['amenity'] ==
                'pub')) {
      return 'nightlife';
    }

    if (selected('nature') &&
        (tags['leisure'] ==
                'park' ||
            tags['leisure'] ==
                'garden' ||
            tags['leisure'] ==
                'nature_reserve')) {
      return 'nature';
    }

    if (selected('shopping') &&
        tags['shop'] != null) {
      return 'shopping';
    }

    if (selected('adventure') &&
        (tags['sport'] != null ||
            tags['leisure'] ==
                'sports_centre')) {
      return 'adventure';
    }

    if (selected('history') &&
        tags['historic'] != null) {
      return 'history';
    }

    return interests.first;
  }

  int _stableId(
    int osmId,
    String osmType,
  ) {
    int typeCode;

    switch (osmType) {
      case 'node':
        typeCode = 1;
        break;

      case 'way':
        typeCode = 2;
        break;

      case 'relation':
        typeCode = 3;
        break;

      default:
        typeCode = 9;
    }

    return (osmId * 10) +
        typeCode;
  }
}