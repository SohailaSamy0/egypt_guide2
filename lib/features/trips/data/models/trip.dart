import 'package:egypt_guide/features/trips/data/models/trip_place.dart';

class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String notes;
  final List<TripPlace> places;

  const Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.notes,
    this.places = const [],
  });

  bool get isCompleted =>
      status == 'completed';

  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? notes,
    List<TripPlace>? places,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination:
          destination ?? this.destination,
      startDate:
          startDate ?? this.startDate,
      endDate:
          endDate ?? this.endDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      places: places ?? this.places,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate':
          startDate.toIso8601String(),
      'endDate':
          endDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'places': places
          .map(
            (place) => place.toJson(),
          )
          .toList(),
    };
  }

  factory Trip.fromJson(
    Map<String, dynamic> json,
  ) {
    final placesJson =
        json['places'] as List<dynamic>? ??
            [];

    return Trip(
      id: json['id']?.toString() ?? '',
      title:
          json['title']?.toString() ?? '',
      destination:
          json['destination']
                  ?.toString() ??
              '',
      startDate: DateTime.tryParse(
            json['startDate']
                    ?.toString() ??
                '',
          ) ??
          DateTime.now(),
      endDate: DateTime.tryParse(
            json['endDate']
                    ?.toString() ??
                '',
          ) ??
          DateTime.now(),
      status:
          json['status']?.toString() ??
              'upcoming',
      notes:
          json['notes']?.toString() ?? '',
      places: placesJson
          .whereType<
              Map<String, dynamic>>()
          .map(
            TripPlace.fromJson,
          )
          .toList(),
    );
  }
}