import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/features/trips/data/models/trip.dart';
import 'package:egypt_guide/features/trips/data/models/trip_place.dart';
import 'package:egypt_guide/features/trips/data/services/trips_service.dart';
import 'package:egypt_guide/features/trips/presentation/screens/trip_day_planner_screen.dart';
import 'package:egypt_guide/features/trips/presentation/screens/trip_route_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;

  const TripDetailsScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailsScreen> createState() =>
      _TripDetailsScreenState();
}

class _TripDetailsScreenState
    extends State<TripDetailsScreen> {
  final TripsService tripsService =
      TripsService();

  Trip? trip;

  bool isLoading = true;
  bool isSavingOrder = false;

  @override
  void initState() {
    super.initState();

    loadTrip();
  }

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> loadTrip() async {
    final loaded =
        await tripsService.getTripById(
      widget.tripId,
    );

    if (!mounted) return;

    setState(() {
      trip = loaded;
      isLoading = false;
    });
  }

  // =========================================================
  // REORDER
  // =========================================================

  Future<void> reorderPlaces(
    int oldIndex,
    int newIndex,
  ) async {
    final currentTrip = trip;

    if (currentTrip == null) {
      return;
    }

    final places =
        List<TripPlace>.from(
      currentTrip.places,
    );

    final moved =
        places.removeAt(
      oldIndex,
    );

    places.insert(
      newIndex,
      moved,
    );

    final updatedTrip =
        currentTrip.copyWith(
      places: places,
    );

    setState(() {
      trip = updatedTrip;
      isSavingOrder = true;
    });

    await tripsService.updateTrip(
      updatedTrip,
    );

    if (!mounted) return;

    setState(() {
      isSavingOrder = false;
    });
  }

  // =========================================================
  // REMOVE
  // =========================================================

  Future<void> removePlace(
    TripPlace place,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Remove Place',
          ),
          content: Text(
            'Remove "${place.name}" from this trip?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'CANCEL',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'REMOVE',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await tripsService
        .removePlaceFromTrip(
      tripId: widget.tripId,
      placeId: place.id,
    );

    await loadTrip();
  }

  // =========================================================
  // FULL ROUTE
  // =========================================================

  void openTripRoute() {
    final currentTrip = trip;

    if (currentTrip == null) {
      return;
    }

    if (currentTrip.places.length < 2) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least 2 places to build a route.',
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TripRouteScreen(
          tripTitle:
              currentTrip.title,
          places:
              currentTrip.places,
        ),
      ),
    );
  }

  // =========================================================
  // DAY PLANNER
  // =========================================================

  void openDayPlanner() {
    final currentTrip = trip;

    if (currentTrip == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TripDayPlannerScreen(
          trip: currentTrip,
        ),
      ),
    );
  }

  // =========================================================
  // DATE
  // =========================================================

  String formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }

  int get tripDays {
    final currentTrip = trip;

    if (currentTrip == null) {
      return 0;
    }

    return currentTrip.endDate
            .difference(
              currentTrip.startDate,
            )
            .inDays +
        1;
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Trip',
          ),
        ),
        body: const Center(
          child: Text(
            'Trip not found.',
          ),
        ),
      );
    }

    final currentTrip = trip!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentTrip.title,
        ),
        actions: [
          if (isSavingOrder)
            const Padding(
              padding:
                  EdgeInsets.only(
                right: 18,
              ),
              child: Center(
                child: SizedBox(
                  width: 19,
                  height: 19,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          // ===================================================
          // HEADER
          // ===================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              0,
            ),
            child: Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                20,
              ),
              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(
                      0xFF078DF5,
                    ),
                    Color(
                      0xFF56C7E8,
                    ),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Colors.white24,
                        child: Icon(
                          Icons
                              .luggage_outlined,
                          color:
                              Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              currentTrip.title,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Row(
                              children: [
                                const Icon(
                                  Icons
                                      .location_on_outlined,
                                  size: 17,
                                  color:
                                      Colors.white70,
                                ),

                                const SizedBox(
                                  width: 4,
                                ),

                                Expanded(
                                  child: Text(
                                    currentTrip
                                        .destination,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _TripHeaderInfo(
                          icon: Icons
                              .calendar_month_outlined,
                          title:
                              'Dates',
                          value:
                              '${formatDate(currentTrip.startDate)}\n'
                              '${formatDate(currentTrip.endDate)}',
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            _TripHeaderInfo(
                          icon:
                              Icons.today_outlined,
                          title:
                              'Duration',
                          value:
                              '$tripDays ${tripDays == 1 ? 'day' : 'days'}',
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            _TripHeaderInfo(
                          icon:
                              Icons.place_outlined,
                          title:
                              'Places',
                          value:
                              '${currentTrip.places.length}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ===================================================
          // ACTIONS
          // ===================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              14,
              18,
              0,
            ),
            child: Column(
              children: [
                SizedBox(
                  width:
                      double.infinity,
                  height: 50,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        currentTrip.places.length <
                                2
                            ? null
                            : openTripRoute,
                    icon:
                        const Icon(
                      Icons.route,
                    ),
                    label:
                        const Text(
                      'BUILD FULL ROUTE',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 50,
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        openDayPlanner,
                    icon:
                        const Icon(
                      Icons
                          .calendar_view_day_outlined,
                    ),
                    label:
                        const Text(
                      'DAY PLANNER',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (currentTrip.places.length <
              2)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                0,
              ),
              child: Text(
                'Add at least 2 places to build the full route.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ),

          // ===================================================
          // NOTES
          // ===================================================

          if (currentTrip.notes
              .isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                14,
                18,
                0,
              ),
              child: Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  14,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  border: Border.all(
                    color: colorScheme
                        .outlineVariant,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_outlined,
                      color: colorScheme
                          .primary,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        currentTrip.notes,
                        style:
                            const TextStyle(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ===================================================
          // TITLE
          // ===================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              20,
              18,
              10,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Trip Plan',
                    style:
                        TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                if (currentTrip
                    .places.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color: colorScheme
                          .primaryContainer,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      '${currentTrip.places.length} places',
                      style:
                          TextStyle(
                        color:
                            colorScheme.primary,
                        fontWeight:
                            FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ===================================================
          // EMPTY
          // ===================================================

          if (currentTrip.places.isEmpty)
            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  30,
                ),
                child: Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    35,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    border: Border.all(
                      color: colorScheme
                          .outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons
                            .add_location_alt_outlined,
                        size: 65,
                        color:
                            colorScheme.primary,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(
                        'No places added yet',
                        style:
                            TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Open a place from the map and choose ADD TO TRIP.',
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ===================================================
          // PLACES
          // ===================================================

          if (currentTrip
              .places.isNotEmpty)
            Expanded(
              child:
                  ReorderableListView.builder(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  30,
                ),
                itemCount:
                    currentTrip
                        .places.length,
                onReorderItem:
                    reorderPlaces,
                buildDefaultDragHandles:
                    false,
                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final place =
                      currentTrip
                          .places[index];

                  return Padding(
                    key: ValueKey(
                      place.id,
                    ),
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child:
                        _TripPlaceCard(
                      place:
                          place,
                      index:
                          index,
                      onRemove:
                          () {
                        removePlace(
                          place,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================
// HEADER INFO
// ===========================================================

class _TripHeaderInfo
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _TripHeaderInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        10,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.16,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                Colors.white,
            size: 18,
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            title,
            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize: 10,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            value,
            maxLines: 2,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 11,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// PLACE CARD
// ===========================================================

class _TripPlaceCard
    extends StatelessWidget {
  final TripPlace place;
  final int index;
  final VoidCallback onRemove;

  const _TripPlaceCard({
    required this.place,
    required this.index,
    required this.onRemove,
  });

  IconData placeIcon() {
    switch (place.category) {
      case 'Restaurants':
      case 'food':
        return Icons
            .restaurant_outlined;

      case 'Cafes':
        return Icons
            .local_cafe_outlined;

      case 'Museums':
      case 'museums':
        return Icons
            .museum_outlined;

      case 'Hotels':
        return Icons
            .hotel_outlined;

      case 'beaches':
        return Icons
            .beach_access_outlined;

      case 'shopping':
        return Icons
            .shopping_bag_outlined;

      case 'nature':
        return Icons
            .park_outlined;

      case 'history':
      case 'ancient_egypt':
        return Icons
            .account_balance_outlined;

      case 'culture':
        return Icons
            .theater_comedy_outlined;

      case 'adventure':
        return Icons
            .hiking_outlined;

      case 'nightlife':
        return Icons
            .nightlife_outlined;

      default:
        return Icons
            .place_outlined;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Material(
      color:
          colorScheme.surface,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      child: Container(
        padding:
            const EdgeInsets.all(
          12,
        ),
        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: colorScheme
                .outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration:
                  BoxDecoration(
                color:
                    colorScheme.primary,
                shape:
                    BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Container(
              width: 43,
              height: 43,
              decoration:
                  BoxDecoration(
                color: colorScheme
                    .primaryContainer,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                placeIcon(),
                color:
                    colorScheme.primary,
              ),
            ),

            const SizedBox(
              width: 11,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    place.category,
                    style:
                        TextStyle(
                      fontSize: 12,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed:
                  onRemove,
              icon:
                  const Icon(
                Icons
                    .delete_outline,
              ),
            ),

            ReorderableDragStartListener(
              index:
                  index,
              child:
                  const Padding(
                padding:
                    EdgeInsets.all(
                  8,
                ),
                child: Icon(
                  Icons.drag_handle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}