import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/features/home/data/models/nearby_place.dart';
import 'package:egypt_guide/features/trips/data/models/trip.dart';
import 'package:egypt_guide/features/trips/data/models/trip_place.dart';
import 'package:egypt_guide/features/trips/data/services/trips_service.dart';

class AddToTripScreen
    extends StatefulWidget {
  final NearbyPlace place;

  const AddToTripScreen({
    super.key,
    required this.place,
  });

  @override
  State<AddToTripScreen> createState() =>
      _AddToTripScreenState();
}

class _AddToTripScreenState
    extends State<AddToTripScreen> {
  final TripsService tripsService =
      TripsService();

  List<Trip> trips = [];

  bool isLoading = true;
  String? addingTripId;

  @override
  void initState() {
    super.initState();

    loadTrips();
  }

  Future<void> loadTrips() async {
    final loaded =
        await tripsService.getTrips();

    if (!mounted) return;

    setState(() {
      trips = loaded
          .where(
            (trip) =>
                !trip.isCompleted,
          )
          .toList();

      isLoading = false;
    });
  }

  Future<void> addToTrip(
    Trip trip,
  ) async {
    setState(() {
      addingTripId =
          trip.id;
    });

    final tripPlace =
        TripPlace(
      id: widget.place.id,
      name: widget.place.name,
      latitude:
          widget.place.latitude,
      longitude:
          widget.place.longitude,
      category:
          widget.place.category,
    );

    final added =
        await tripsService
            .addPlaceToTrip(
      tripId: trip.id,
      place: tripPlace,
    );

    if (!mounted) return;

    setState(() {
      addingTripId = null;
    });

    if (!added) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'This place is already in this trip.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${widget.place.name} added to ${trip.title}.',
        ),
      ),
    );

    Navigator.pop(
      context,
      true,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add to Trip',
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : trips.isEmpty
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      30,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .luggage_outlined,
                          size: 75,
                          color:
                              colorScheme.primary,
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        const Text(
                          'No Upcoming Trips',
                          style:
                              TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          'Create a trip first from Profile → My Trips, then you can add places to it.',
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            height: 1.5,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding:
                      const EdgeInsets.all(
                    18,
                  ),
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(
                        18,
                      ),
                      decoration:
                          BoxDecoration(
                        color: colorScheme
                            .primaryContainer,
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .place_outlined,
                            size: 35,
                            color: colorScheme
                                .primary,
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Adding',
                                  style:
                                      TextStyle(
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                Text(
                                  widget
                                      .place.name,
                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    const Text(
                      'Choose a Trip',
                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ...trips.map(
                      (trip) {
                        final isAdding =
                            addingTripId ==
                                trip.id;

                        final alreadySaved =
                            trip.places.any(
                          (place) =>
                              place.id ==
                              widget.place.id,
                        );

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Card(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets
                                      .all(
                                14,
                              ),
                              leading:
                                  CircleAvatar(
                                child: Icon(
                                  alreadySaved
                                      ? Icons
                                          .check
                                      : Icons
                                          .luggage_outlined,
                                ),
                              ),
                              title: Text(
                                trip.title,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              subtitle: Text(
                                '${trip.destination}\n'
                                '${trip.places.length} places',
                              ),
                              isThreeLine: true,
                              trailing: isAdding
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    )
                                  : alreadySaved
                                      ? const Icon(
                                          Icons
                                              .check_circle,
                                          color:
                                              Colors.green,
                                        )
                                      : const Icon(
                                          Icons
                                              .add_circle_outline,
                                        ),
                              onTap: isAdding
                                  ? null
                                  : () {
                                      addToTrip(
                                        trip,
                                      );
                                    },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}