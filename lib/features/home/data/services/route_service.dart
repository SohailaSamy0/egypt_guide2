import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:egypt_guide/features/home/data/models/route_result.dart';

class RouteService {
  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  Future<RouteResult> getDrivingRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    return _getRoute(
      [
        LatLng(
          startLatitude,
          startLongitude,
        ),
        LatLng(
          endLatitude,
          endLongitude,
        ),
      ],
    );
  }

  Future<RouteResult> getMultiStopDrivingRoute({
    required List<LatLng> stops,
  }) async {
    if (stops.length < 2) {
      throw Exception(
        'At least two places are required to build a route.',
      );
    }

    return _getRoute(
      stops,
    );
  }

  Future<RouteResult> _getRoute(
    List<LatLng> stops,
  ) async {
    final coordinates = stops
        .map(
          (point) =>
              '${point.longitude},${point.latitude}',
        )
        .join(';');

    final uri = Uri.parse(
      '$_baseUrl/$coordinates'
      '?overview=full'
      '&geometries=geojson'
      '&steps=false',
    );

    final response = await http.get(
      uri,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Route request failed: ${response.statusCode}',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final code =
        data['code']?.toString();

    if (code != 'Ok') {
      throw Exception(
        'Could not calculate route.',
      );
    }

    final routes =
        data['routes']
                as List<dynamic>? ??
            [];

    if (routes.isEmpty) {
      throw Exception(
        'No route was found.',
      );
    }

    final route =
        routes.first
            as Map<String, dynamic>;

    final geometry =
        route['geometry']
            as Map<String, dynamic>?;

    final coordinatesList =
        geometry?['coordinates']
                as List<dynamic>? ??
            [];

    final points =
        coordinatesList.map(
      (coordinate) {
        final values =
            coordinate as List<dynamic>;

        final longitude =
            (values[0] as num)
                .toDouble();

        final latitude =
            (values[1] as num)
                .toDouble();

        return LatLng(
          latitude,
          longitude,
        );
      },
    ).toList();

    final distanceMeters =
        (route['distance'] as num?)
                ?.toDouble() ??
            0;

    final durationSeconds =
        (route['duration'] as num?)
                ?.toDouble() ??
            0;

    return RouteResult(
      points: points,
      distanceKm:
          distanceMeters / 1000,
      durationMinutes:
          durationSeconds / 60,
    );
  }
}