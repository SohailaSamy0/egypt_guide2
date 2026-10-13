class FlightOffer {
  final String id;
  final String airlineName;
  final String airlineIataCode;
  final String flightNumber;
  final String origin;
  final String destination;
  final DateTime departureAt;
  final DateTime arrivalAt;
  final String duration;
  final double totalAmount;
  final String currency;
  final int stops;
  final List<String> passengerIds;
  final bool liveMode;

  const FlightOffer({
    required this.id,
    required this.airlineName,
    required this.airlineIataCode,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.departureAt,
    required this.arrivalAt,
    required this.duration,
    required this.totalAmount,
    required this.currency,
    required this.stops,
    required this.passengerIds,
    required this.liveMode,
  });

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    return FlightOffer(
      id: json['id']?.toString() ?? '',
      airlineName: json['airlineName']?.toString() ?? 'Airline',
      airlineIataCode: json['airlineIataCode']?.toString() ?? '',
      flightNumber: json['flightNumber']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      departureAt: DateTime.parse(json['departureAt'].toString()),
      arrivalAt: DateTime.parse(json['arrivalAt'].toString()),
      duration: json['duration']?.toString() ?? '',
      totalAmount: _toDouble(json['totalAmount']),
      currency: json['currency']?.toString() ?? '',
      stops: (json['stops'] as num?)?.toInt() ?? 0,
      passengerIds: (json['passengerIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(),
      liveMode: json['liveMode'] == true,
    );
  }
}


double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
