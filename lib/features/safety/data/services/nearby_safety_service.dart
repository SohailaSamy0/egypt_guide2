import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:egypt_guide/features/home/data/models/nearby_place.dart';

class NearbySafetyService {
  static const String _endpoint =
      'https://overpass-api.de/api/interpreter';

  Future<List<NearbyPlace>> getNearbyHelp({
    required double latitude,
    required double longitude,
    required String type,
    int radiusMeters = 5000,
  }) async {
    final tag = _tagForType(type);

    final query = '''
[out:json][timeout:20];
(
  node(around:$radiusMeters,$latitude,$longitude)$tag;
  way(around:$radiusMeters,$latitude,$longitude)$tag;
  relation(around:$radiusMeters,$latitude,$longitude)$tag;
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
        'Nearby safety request failed: ${response.statusCode}',
      );
    }

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final elements =
        data['elements'] as List<dynamic>? ?? [];

    final places = <NearbyPlace>[];

    for (final raw in elements) {
      final element =
          raw as Map<String, dynamic>;

      final tags =
          (element['tags']
                  as Map<String, dynamic>?) ??
              {};

      final name =
          tags['name']?.toString().trim();

      double? lat;
      double? lon;

      if (element['lat'] != null &&
          element['lon'] != null) {
        lat =
            (element['lat'] as num).toDouble();

        lon =
            (element['lon'] as num).toDouble();
      } else {
        final center =
            element['center']
                as Map<String, dynamic>?;

        if (center != null &&
            center['lat'] != null &&
            center['lon'] != null) {
          lat =
              (center['lat'] as num).toDouble();

          lon =
              (center['lon'] as num).toDouble();
        }
      }

      if (lat == null || lon == null) {
        continue;
      }

      final osmId =
          (element['id'] as num).toInt();

      final osmType =
          element['type']?.toString() ??
              'node';

      places.add(
        NearbyPlace(
          id: _stableId(
            osmId,
            osmType,
          ),
          name:
              (name == null || name.isEmpty)
                  ? _fallbackName(type)
                  : name,
          latitude: lat,
          longitude: lon,
          category: type,
        ),
      );
    }

    final origin =
        LatLng(latitude, longitude);

    final distance = Distance();

    places.sort(
      (a, b) {
        final distanceA = distance.as(
          LengthUnit.Meter,
          origin,
          LatLng(
            a.latitude,
            a.longitude,
          ),
        );

        final distanceB = distance.as(
          LengthUnit.Meter,
          origin,
          LatLng(
            b.latitude,
            b.longitude,
          ),
        );

        return distanceA.compareTo(
          distanceB,
        );
      },
    );

    return places.take(15).toList();
  }

  String _tagForType(String type) {
    switch (type) {
      case 'Hospital':
        return '["amenity"="hospital"]';

      case 'Pharmacy':
        return '["amenity"="pharmacy"]';

      case 'Police':
        return '["amenity"="police"]';

      default:
        throw ArgumentError(
          'Unsupported safety place type: $type',
        );
    }
  }

  String _fallbackName(String type) {
    switch (type) {
      case 'Hospital':
        return 'Hospital';

      case 'Pharmacy':
        return 'Pharmacy';

      case 'Police':
        return 'Police Station';

      default:
        return 'Nearby Help';
    }
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

    return (osmId * 10) + typeCode;
  }
}