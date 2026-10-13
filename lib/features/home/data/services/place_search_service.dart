import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:egypt_guide/features/home/data/models/place_search_result.dart';

class PlaceSearchService {
  Future<List<PlaceSearchResult>> searchPlaces(
    String query,
  ) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return [];
    }

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': trimmedQuery,
        'format': 'jsonv2',
        'limit': '6',
        'countrycodes': 'eg',
        'addressdetails': '1',
      },
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Language': 'en',
    };

    // On Android identify our application.
    // On Web the browser provides the Referer.
    if (!kIsWeb) {
      headers['User-Agent'] = 'EgyptGuide/1.0';
    }

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Search failed: ${response.statusCode}',
      );
    }

    final decoded =
        jsonDecode(response.body) as List<dynamic>;

    return decoded
        .map(
          (item) => PlaceSearchResult.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .where(
          (place) =>
              place.latitude != 0 &&
              place.longitude != 0,
        )
        .toList();
  }
}