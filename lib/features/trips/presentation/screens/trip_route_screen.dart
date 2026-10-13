import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:egypt_guide/features/home/data/models/route_result.dart';
import 'package:egypt_guide/features/home/data/services/route_service.dart';

import 'package:egypt_guide/features/trips/data/models/trip_place.dart';

class TripRouteScreen extends StatefulWidget {
  final String tripTitle;
  final List<TripPlace> places;

  const TripRouteScreen({
    super.key,
    required this.tripTitle,
    required this.places,
  });

  @override
  State<TripRouteScreen> createState() =>
      _TripRouteScreenState();
}

class _TripRouteScreenState
    extends State<TripRouteScreen> {
  final RouteService routeService =
      RouteService();

  RouteResult? route;

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    buildRoute();
  }

  Future<void> buildRoute() async {
    if (widget.places.length < 2) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Add at least two places to build a route.';
      });

      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final stops =
          widget.places.map(
        (place) {
          return LatLng(
            place.latitude,
            place.longitude,
          );
        },
      ).toList();

      final result =
          await routeService
              .getMultiStopDrivingRoute(
        stops: stops,
      );

      if (!mounted) return;

      setState(() {
        route = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Could not build trip route. Please try again.';
      });
    }
  }

  LatLng get mapCenter {
    if (route != null &&
        route!.points.isNotEmpty) {
      double latitude = 0;
      double longitude = 0;

      for (final point
          in route!.points) {
        latitude +=
            point.latitude;

        longitude +=
            point.longitude;
      }

      return LatLng(
        latitude /
            route!.points.length,
        longitude /
            route!.points.length,
      );
    }

    if (widget.places.isNotEmpty) {
      double latitude = 0;
      double longitude = 0;

      for (final place
          in widget.places) {
        latitude +=
            place.latitude;

        longitude +=
            place.longitude;
      }

      return LatLng(
        latitude /
            widget.places.length,
        longitude /
            widget.places.length,
      );
    }

    return const LatLng(
      30.0444,
      31.2357,
    );
  }

  double get mapZoom {
    final distance =
        route?.distanceKm ?? 0;

    if (distance < 3) {
      return 14;
    }

    if (distance < 8) {
      return 13;
    }

    if (distance < 20) {
      return 12;
    }

    if (distance < 50) {
      return 10.5;
    }

    if (distance < 150) {
      return 9;
    }

    return 7;
  }

  String formatDuration(
    double minutes,
  ) {
    final totalMinutes =
        minutes.round();

    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }

    final hours =
        totalMinutes ~/ 60;

    final remainingMinutes =
        totalMinutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hr';
    }

    return '$hours hr ${remainingMinutes}m';
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
        title: Text(
          '${widget.tripTitle} Route',
        ),
        actions: [
          IconButton(
            tooltip: 'Rebuild Route',
            onPressed:
                isLoading
                    ? null
                    : buildRoute,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),

                  SizedBox(
                    height: 15,
                  ),

                  Text(
                    'Building your trip route...',
                  ),
                ],
              ),
            )

          // ===============================================
          // ERROR
          // ===============================================

          : errorMessage != null
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
                              .route_outlined,
                          size: 70,
                          color:
                              colorScheme.primary,
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Text(
                          errorMessage!,
                          textAlign:
                              TextAlign.center,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        ElevatedButton.icon(
                          onPressed:
                              buildRoute,
                          icon:
                              const Icon(
                            Icons.refresh,
                          ),
                          label:
                              const Text(
                            'TRY AGAIN',
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // ===============================================
              // ROUTE
              // ===============================================

              : Column(
                  children: [
                    // =========================================
                    // MAP
                    // =========================================

                    Expanded(
                      child: FlutterMap(
                        options:
                            MapOptions(
                          initialCenter:
                              mapCenter,
                          initialZoom:
                              mapZoom,
                          minZoom: 3,
                          maxZoom: 19,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'egypt_guide',
                            maxNativeZoom:
                                19,
                          ),

                          if (route !=
                              null)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points:
                                      route!
                                          .points,
                                  strokeWidth:
                                      6,
                                  color:
                                      colorScheme
                                          .primary,
                                ),
                              ],
                            ),

                          MarkerLayer(
                            markers:
                                List.generate(
                              widget
                                  .places
                                  .length,
                              (index) {
                                final place =
                                    widget.places[
                                        index];

                                return Marker(
                                  point:
                                      LatLng(
                                    place
                                        .latitude,
                                    place
                                        .longitude,
                                  ),
                                  width: 48,
                                  height: 48,
                                  child:
                                      Container(
                                    decoration:
                                        BoxDecoration(
                                      color: index ==
                                              0
                                          ? Colors
                                              .green
                                          : index ==
                                                  widget.places.length -
                                                      1
                                              ? Colors
                                                  .red
                                              : colorScheme
                                                  .primary,
                                      shape:
                                          BoxShape
                                              .circle,
                                      border:
                                          Border.all(
                                        color:
                                            Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow:
                                          const [
                                        BoxShadow(
                                          color:
                                              Colors.black26,
                                          blurRadius:
                                              5,
                                        ),
                                      ],
                                    ),
                                    child:
                                        Center(
                                      child:
                                          Text(
                                        '${index + 1}',
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              16,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SimpleAttributionWidget(
                            source:
                                Text(
                              'OpenStreetMap contributors',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =========================================
                    // SUMMARY
                    // =========================================

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        15,
                        16,
                        8,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            colorScheme.surface,
                        boxShadow:
                            const [
                          BoxShadow(
                            color:
                                Colors.black12,
                            blurRadius:
                                8,
                            offset:
                                Offset(
                              0,
                              -2,
                            ),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                _RouteSummaryBox(
                              icon: Icons
                                  .route_outlined,
                              title:
                                  'Distance',
                              value:
                                  '${route!.distanceKm.toStringAsFixed(1)} km',
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child:
                                _RouteSummaryBox(
                              icon: Icons
                                  .schedule_outlined,
                              title:
                                  'Driving',
                              value:
                                  formatDuration(
                                route!
                                    .durationMinutes,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child:
                                _RouteSummaryBox(
                              icon: Icons
                                  .place_outlined,
                              title:
                                  'Stops',
                              value:
                                  '${widget.places.length}',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =========================================
                    // ROUTE ORDER
                    // =========================================

                    SizedBox(
                      height: 230,
                      child:
                          ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          20,
                        ),
                        itemCount:
                            widget
                                .places
                                .length,
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final place =
                              widget
                                  .places[
                            index
                          ];

                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 34,
                                    height:
                                        34,
                                    decoration:
                                        BoxDecoration(
                                      color: index ==
                                              0
                                          ? Colors
                                              .green
                                          : index ==
                                                  widget.places.length -
                                                      1
                                              ? Colors
                                                  .red
                                              : colorScheme
                                                  .primary,
                                      shape:
                                          BoxShape
                                              .circle,
                                    ),
                                    child:
                                        Center(
                                      child:
                                          Text(
                                        '${index + 1}',
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (index !=
                                      widget
                                              .places
                                              .length -
                                          1)
                                    Container(
                                      width: 2,
                                      height:
                                          45,
                                      color: colorScheme
                                          .outlineVariant,
                                    ),
                                ],
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child:
                                    Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 4,
                                    bottom:
                                        18,
                                  ),
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        place.name,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        place.category,
                                        style:
                                            TextStyle(
                                          fontSize:
                                              12,
                                          color:
                                              colorScheme
                                                  .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _RouteSummaryBox
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _RouteSummaryBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(
        10,
      ),
      decoration:
          BoxDecoration(
        color: colorScheme
            .primaryContainer,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color:
                colorScheme.primary,
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            title,
            style:
                TextStyle(
              fontSize: 10,
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            value,
            textAlign:
                TextAlign.center,
            maxLines: 2,
            style:
                const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}