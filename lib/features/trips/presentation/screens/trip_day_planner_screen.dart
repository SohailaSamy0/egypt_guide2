import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/features/trips/data/models/trip.dart';
import 'package:egypt_guide/features/trips/data/models/trip_place.dart';
import 'package:egypt_guide/features/trips/presentation/screens/trip_route_screen.dart';

class TripDayPlannerScreen extends StatelessWidget {
  final Trip trip;

  const TripDayPlannerScreen({
    super.key,
    required this.trip,
  });

  int get tripDays {
    final difference =
        trip.endDate.difference(trip.startDate).inDays;

    return difference + 1;
  }

  List<List<TripPlace>> buildDayPlan() {
    final days =
        List.generate(
      tripDays,
      (_) => <TripPlace>[],
    );

    if (trip.places.isEmpty) {
      return days;
    }

    final basePlacesPerDay =
        trip.places.length ~/ tripDays;

    final extraPlaces =
        trip.places.length % tripDays;

    int currentPlaceIndex = 0;

    for (int dayIndex = 0;
        dayIndex < tripDays;
        dayIndex++) {
      final countForThisDay =
          basePlacesPerDay +
              (dayIndex < extraPlaces ? 1 : 0);

      for (int i = 0;
          i < countForThisDay;
          i++) {
        if (currentPlaceIndex >=
            trip.places.length) {
          break;
        }

        days[dayIndex].add(
          trip.places[currentPlaceIndex],
        );

        currentPlaceIndex++;
      }
    }

    return days;
  }

  DateTime dateForDay(
    int dayIndex,
  ) {
    return trip.startDate.add(
      Duration(
        days: dayIndex,
      ),
    );
  }

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

  String weekdayName(
    DateTime date,
  ) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';

      case DateTime.tuesday:
        return 'Tuesday';

      case DateTime.wednesday:
        return 'Wednesday';

      case DateTime.thursday:
        return 'Thursday';

      case DateTime.friday:
        return 'Friday';

      case DateTime.saturday:
        return 'Saturday';

      case DateTime.sunday:
        return 'Sunday';

      default:
        return '';
    }
  }

  IconData placeIcon(
    String category,
  ) {
    switch (category) {
      case 'Restaurants':
      case 'food':
        return Icons.restaurant_outlined;

      case 'Cafes':
        return Icons.local_cafe_outlined;

      case 'Museums':
      case 'museums':
        return Icons.museum_outlined;

      case 'Hotels':
        return Icons.hotel_outlined;

      case 'beaches':
        return Icons.beach_access_outlined;

      case 'shopping':
        return Icons.shopping_bag_outlined;

      case 'nature':
        return Icons.park_outlined;

      case 'history':
      case 'ancient_egypt':
        return Icons.account_balance_outlined;

      case 'culture':
        return Icons.theater_comedy_outlined;

      case 'adventure':
        return Icons.hiking_outlined;

      case 'nightlife':
        return Icons.nightlife_outlined;

      case 'Hospital':
        return Icons.local_hospital_outlined;

      case 'Pharmacy':
        return Icons.local_pharmacy_outlined;

      case 'Police':
        return Icons.local_police_outlined;

      default:
        return Icons.place_outlined;
    }
  }

  void openDayRoute(
    BuildContext context,
    int dayNumber,
    List<TripPlace> places,
  ) {
    if (places.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least 2 places to build a route for this day.',
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
              '${trip.title} - Day $dayNumber',
          places: places,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final dayPlan =
        buildDayPlan();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Day Planner',
        ),
      ),

      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          30,
        ),
        children: [
          // ===================================================
          // HEADER
          // ===================================================

          Container(
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
                const Icon(
                  Icons
                      .calendar_month_outlined,
                  color:
                      Colors.white,
                  size: 38,
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  trip.title,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  trip.destination,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _HeaderInfoBox(
                        icon: Icons
                            .today_outlined,
                        title:
                            'Days',
                        value:
                            '$tripDays',
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                          _HeaderInfoBox(
                        icon: Icons
                            .place_outlined,
                        title:
                            'Places',
                        value:
                            '${trip.places.length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Container(
            padding:
                const EdgeInsets.all(
              14,
            ),
            decoration:
                BoxDecoration(
              color: colorScheme
                  .primaryContainer,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons
                      .auto_awesome_outlined,
                  color:
                      colorScheme.primary,
                ),

                const SizedBox(
                  width: 10,
                ),

                const Expanded(
                  child: Text(
                    'Egypt Guide automatically divides your places across the trip days while keeping your chosen visit order.',
                    style:
                        TextStyle(
                      height: 1.45,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          if (trip.places.isEmpty)
            Container(
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
                  color:
                      colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons
                        .event_busy_outlined,
                    size: 60,
                    color:
                        colorScheme.primary,
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  const Text(
                    'No places to plan',
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
                    'Add places to this trip first, then Egypt Guide can divide them across your trip days.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color: colorScheme
                          .onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

          // ===================================================
          // DAYS
          // ===================================================

          ...List.generate(
            dayPlan.length,
            (dayIndex) {
              final places =
                  dayPlan[dayIndex];

              final dayDate =
                  dateForDay(
                dayIndex,
              );

              final dayNumber =
                  dayIndex + 1;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 18,
                ),
                child:
                    _DayPlanCard(
                  dayNumber:
                      dayNumber,
                  date:
                      '${weekdayName(dayDate)} • ${formatDate(dayDate)}',
                  places:
                      places,
                  placeIcon:
                      placeIcon,
                  onBuildRoute:
                      places.length < 2
                          ? null
                          : () {
                              openDayRoute(
                                context,
                                dayNumber,
                                places,
                              );
                            },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// DAY PLAN CARD
// ===========================================================

class _DayPlanCard
    extends StatelessWidget {
  final int dayNumber;
  final String date;
  final List<TripPlace> places;

  final IconData Function(
    String category,
  ) placeIcon;

  final VoidCallback? onBuildRoute;

  const _DayPlanCard({
    required this.dayNumber,
    required this.date,
    required this.places,
    required this.placeIcon,
    required this.onBuildRoute,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          // =================================================
          // DAY HEADER
          // =================================================

          Container(
            padding:
                const EdgeInsets.all(
              15,
            ),
            decoration:
                BoxDecoration(
              color: colorScheme
                  .primaryContainer,
              borderRadius:
                  const BorderRadius.only(
                topLeft:
                    Radius.circular(
                  19,
                ),
                topRight:
                    Radius.circular(
                  19,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration:
                      BoxDecoration(
                    color:
                        colorScheme.primary,
                    shape:
                        BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
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
                      Text(
                        'Day $dayNumber',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        date,
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

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    '${places.length} places',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // NO PLACES
          // =================================================

          if (places.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.all(
                25,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons
                        .free_breakfast_outlined,
                    color: colorScheme
                        .onSurfaceVariant,
                    size: 36,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Free day',
                    style:
                        TextStyle(
                      color: colorScheme
                          .onSurfaceVariant,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'No places scheduled for this day.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color: colorScheme
                          .onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // =================================================
          // PLACES
          // =================================================

          ...List.generate(
            places.length,
            (index) {
              final place =
                  places[index];

              return Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  15,
                  14,
                  15,
                  0,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
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

                        if (index <
                            places.length -
                                1)
                          Container(
                            width: 2,
                            height: 42,
                            color: colorScheme
                                .outlineVariant,
                          ),
                      ],
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Container(
                      width: 40,
                      height: 40,
                      decoration:
                          BoxDecoration(
                        color: colorScheme
                            .primaryContainer,
                        borderRadius:
                            BorderRadius.circular(
                          11,
                        ),
                      ),
                      child: Icon(
                        placeIcon(
                          place.category,
                        ),
                        size: 21,
                        color:
                            colorScheme.primary,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              place.name,
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
                    ),
                  ],
                ),
              );
            },
          ),

          if (places.isNotEmpty)
            const SizedBox(
              height: 14,
            ),

          // =================================================
          // DAY ROUTE
          // =================================================

          if (places.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                15,
                0,
                15,
                15,
              ),
              child: SizedBox(
                width:
                    double.infinity,
                child:
                    OutlinedButton.icon(
                  onPressed:
                      onBuildRoute,
                  icon: const Icon(
                    Icons.route,
                  ),
                  label: Text(
                    places.length < 2
                        ? 'NEED 2 PLACES FOR ROUTE'
                        : 'BUILD DAY $dayNumber ROUTE',
                  ),
                ),
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

class _HeaderInfoBox
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _HeaderInfoBox({
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
        12,
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
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),

          const SizedBox(
            width: 8,
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
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
                height: 2,
              ),

              Text(
                value,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}