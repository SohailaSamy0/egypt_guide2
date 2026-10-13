class FlightSeatService {
  final String passengerId;
  final String serviceId;
  final double amount;
  final String currency;

  const FlightSeatService({
    required this.passengerId,
    required this.serviceId,
    required this.amount,
    required this.currency,
  });

  factory FlightSeatService.fromJson(Map<String, dynamic> json) {
    return FlightSeatService(
      passengerId: json['passengerId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      currency: json['currency']?.toString() ?? '',
    );
  }
}

class FlightSeat {
  final String designator;
  final bool available;
  final List<FlightSeatService> services;

  const FlightSeat({
    required this.designator,
    required this.available,
    required this.services,
  });

  factory FlightSeat.fromJson(Map<String, dynamic> json) {
    return FlightSeat(
      designator: json['designator']?.toString() ?? '',
      available: json['available'] == true,
      services: (json['services'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => FlightSeatService.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  FlightSeatService? serviceForPassenger(String passengerId) {
    for (final service in services) {
      if (service.passengerId == passengerId) {
        return service;
      }
    }
    return null;
  }
}

class SelectedFlightSeat {
  final String passengerId;
  final String designator;
  final String serviceId;
  final double amount;
  final String currency;

  const SelectedFlightSeat({
    required this.passengerId,
    required this.designator,
    required this.serviceId,
    required this.amount,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
        'passengerId': passengerId,
        'designator': designator,
        'serviceId': serviceId,
        'amount': amount,
        'currency': currency,
      };
}


double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
