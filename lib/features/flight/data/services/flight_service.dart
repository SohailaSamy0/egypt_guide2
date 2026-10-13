import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:egypt_guide/features/flight/data/models/flight_booking.dart';
import 'package:egypt_guide/features/flight/data/models/flight_offer.dart';
import 'package:egypt_guide/features/flight/data/models/flight_seat.dart';

class FlightService {
  static const String _baseUrl =
      'https://egypt-guide-api.sohilasamy882006.workers.dev';

  Future<List<FlightOffer>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    required int travelers,
    required String travelClass,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/search-flights'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'origin': origin.trim().toUpperCase(),
        'destination': destination.trim().toUpperCase(),
        'departureDate': _formatDate(departureDate),
        'travelers': travelers,
        'travelClass': _normalizeCabin(travelClass),
      }),
    );

    final data = _decodeResponse(response);
    final rawOffers = data['offers'];

    if (rawOffers is! List) {
      return [];
    }

    return rawOffers
        .whereType<Map>()
        .map((item) => FlightOffer.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<FlightOffer> refreshOffer(String offerId) async {
    final uri = Uri.parse('$_baseUrl/flight-offer').replace(
      queryParameters: {'offerId': offerId},
    );

    final response = await http.get(uri, headers: const {'Accept': 'application/json'});
    final data = _decodeResponse(response);
    return FlightOffer.fromJson(Map<String, dynamic>.from(data['offer'] as Map));
  }

  Future<List<FlightSeat>> getSeatMap(String offerId) async {
    final uri = Uri.parse('$_baseUrl/seat-map').replace(
      queryParameters: {'offerId': offerId},
    );

    final response = await http.get(uri, headers: const {'Accept': 'application/json'});
    final data = _decodeResponse(response);
    final rawSeats = data['seats'];

    if (rawSeats is! List) {
      return [];
    }

    return rawSeats
        .whereType<Map>()
        .map((item) => FlightSeat.fromJson(Map<String, dynamic>.from(item)))
        .where((seat) => seat.designator.isNotEmpty)
        .toList();
  }

  Future<FlightBooking> createBooking({
    required String offerId,
    required String paymentReference,
    required List<Map<String, dynamic>> passengers,
    required List<SelectedFlightSeat> selectedSeats,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/create-flight-booking'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'offerId': offerId,
        'paymentReference': paymentReference,
        'passengers': passengers,
        'seats': selectedSeats.map((seat) => seat.toJson()).toList(),
      }),
    );

    final data = _decodeResponse(response);
    return FlightBooking.fromJson(data);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw Exception('The flight service returned an invalid response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ?? 'Could not complete the flight request.',
      );
    }

    if (data['success'] == false) {
      throw Exception(
        data['message']?.toString() ?? 'Could not complete the flight request.',
      );
    }

    return data;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _normalizeCabin(String value) {
    switch (value.toLowerCase()) {
      case 'premium economy':
        return 'premium_economy';
      case 'business':
        return 'business';
      case 'first':
        return 'first';
      default:
        return 'economy';
    }
  }
}
