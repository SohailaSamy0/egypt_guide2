import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:latlong2/latlong.dart';

import 'package:egypt_guide/core/localization/app_localizations.dart';

import 'package:egypt_guide/features/home/data/models/nearby_place.dart';
import 'package:egypt_guide/features/home/data/services/recommendation_service.dart';

import 'package:egypt_guide/features/preferences/data/services/interests_service.dart';
import 'package:egypt_guide/features/preferences/presentation/screens/interests_screen.dart';

class RecommendationsScreen
    extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const RecommendationsScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<RecommendationsScreen>
      createState() =>
          _RecommendationsScreenState();
}

class _RecommendationsScreenState
    extends State<RecommendationsScreen> {
  final InterestsService interestsService =
      InterestsService();

  final RecommendationService
      recommendationService =
      RecommendationService();

  List<String> interests = [];
  List<NearbyPlace> places = [];

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final savedInterests =
          await interestsService
              .getSelectedInterests();

      if (!mounted) return;

      if (savedInterests.isEmpty) {
        setState(() {
          interests = [];
          places = [];
          isLoading = false;
        });

        return;
      }

      if (widget.latitude == null ||
          widget.longitude == null) {
        setState(() {
          interests = savedInterests;

          places = [];

          errorMessage =
              'Enable your location to see recommendations near you.';

          isLoading = false;
        });

        return;
      }

      final results =
          await recommendationService
              .getRecommendations(
        latitude: widget.latitude!,
        longitude: widget.longitude!,
        interests: savedInterests,
      );

      if (!mounted) return;

      setState(() {
        interests = savedInterests;
        places = results;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Could not load recommendations. Please try again.';

        isLoading = false;
      });
    }
  }

  Future<void> editInterests() async {
    final changed =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const InterestsScreen(
          editMode: true,
        ),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await loadRecommendations();
    }
  }

  String interestName(
    String interest,
  ) {
    return context.tr(
      interest,
    );
  }

  IconData interestIcon(
    String interest,
  ) {
    switch (interest) {
      case 'history':
        return Icons.account_balance_outlined;

      case 'museums':
        return Icons.museum_outlined;

      case 'food':
        return Icons.restaurant_outlined;

      case 'beaches':
        return Icons.beach_access_outlined;

      case 'shopping':
        return Icons.shopping_bag_outlined;

      case 'adventure':
        return Icons.hiking_outlined;

      case 'ancient_egypt':
        return Icons.temple_hindu_outlined;

      case 'culture':
        return Icons.theater_comedy_outlined;

      case 'nature':
        return Icons.park_outlined;

      case 'nightlife':
        return Icons.nightlife_outlined;

      default:
        return Icons.place_outlined;
    }
  }

  double distanceToPlace(
    NearbyPlace place,
  ) {
    if (widget.latitude == null ||
        widget.longitude == null) {
      return 0;
    }

    final distance = Distance();

    return distance.as(
      LengthUnit.Kilometer,
      LatLng(
        widget.latitude!,
        widget.longitude!,
      ),
      LatLng(
        place.latitude,
        place.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'For You',
        ),
        actions: [
          if (interests.isNotEmpty)
            IconButton(
              tooltip:
                  'Edit Interests',
              onPressed:
                  editInterests,
              icon: const Icon(
                Icons.tune,
              ),
            ),

          IconButton(
            tooltip: 'Refresh',
            onPressed:
                loadRecommendations,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          // ============================
          // NO INTERESTS
          // ============================
          : interests.isEmpty
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
                        Container(
                          width: 110,
                          height: 110,
                          decoration:
                              BoxDecoration(
                            color: colorScheme
                                .primaryContainer,
                            shape:
                                BoxShape.circle,
                          ),
                          child: Icon(
                            Icons
                                .interests_outlined,
                            size: 60,
                            color: colorScheme
                                .primary,
                          ),
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        const Text(
                          'Choose Your Interests',
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          'Tell us what you enjoy and Egypt Guide will recommend places near you.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            height: 1.5,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        SizedBox(
                          width: 230,
                          height: 50,
                          child:
                              ElevatedButton.icon(
                            onPressed:
                                editInterests,
                            icon:
                                const Icon(
                              Icons
                                  .add_circle_outline,
                            ),
                            label:
                                const Text(
                              'CHOOSE INTERESTS',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // ============================
              // LOCATION ERROR
              // ============================
              : errorMessage != null
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(
                          25,
                        ),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            const Icon(
                              Icons
                                  .location_off_outlined,
                              size: 65,
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            Text(
                              errorMessage!,
                              textAlign:
                                  TextAlign
                                      .center,
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            ElevatedButton(
                              onPressed:
                                  loadRecommendations,
                              child:
                                  const Text(
                                'TRY AGAIN',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )

                  // ============================
                  // RECOMMENDATIONS
                  // ============================
                  : RefreshIndicator(
                      onRefresh:
                          loadRecommendations,
                      child:
                          ListView(
                        padding:
                            const EdgeInsets
                                .all(
                          18,
                        ),
                        children: [
                          Container(
                            padding:
                                const EdgeInsets
                                    .all(
                              18,
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
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child:
                                const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Icon(
                                  Icons
                                      .auto_awesome,
                                  color:
                                      Colors.white,
                                  size: 34,
                                ),

                                SizedBox(
                                  height: 10,
                                ),

                                Text(
                                  'Recommended for You',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  'Places selected using your interests and current location.',
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white70,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Your Interests',
                                  style:
                                      TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),

                              TextButton.icon(
                                onPressed:
                                    editInterests,
                                icon:
                                    const Icon(
                                  Icons.edit,
                                  size: 17,
                                ),
                                label:
                                    const Text(
                                  'EDIT',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                interests.map(
                              (interest) {
                                return Chip(
                                  avatar:
                                      Icon(
                                    interestIcon(
                                      interest,
                                    ),
                                    size: 17,
                                  ),
                                  label: Text(
                                    interestName(
                                      interest,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),

                          const SizedBox(
                            height: 25,
                          ),

                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Places Near You',
                                  style:
                                      TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),

                              Text(
                                '${places.length} places',
                                style:
                                    TextStyle(
                                  color: colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          if (places.isEmpty)
                            Container(
                              padding:
                                  const EdgeInsets
                                      .all(
                                25,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: colorScheme
                                    .surface,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                              ),
                              child:
                                  const Text(
                                'No matching places were found nearby. Try changing your interests or try again from another location.',
                                textAlign:
                                    TextAlign
                                        .center,
                              ),
                            ),

                          ...places.map(
                            (place) {
                              final km =
                                  distanceToPlace(
                                place,
                              );

                              return Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  bottom: 10,
                                ),
                                child: Card(
                                  child:
                                      ListTile(
                                    contentPadding:
                                        const EdgeInsets
                                            .all(
                                      12,
                                    ),
                                    leading:
                                        CircleAvatar(
                                      radius: 25,
                                      child: Icon(
                                        interestIcon(
                                          place
                                              .category,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      place.name,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    subtitle:
                                        Padding(
                                      padding:
                                          const EdgeInsets
                                              .only(
                                        top: 5,
                                      ),
                                      child: Text(
                                        '${interestName(place.category)} • '
                                        '${km.toStringAsFixed(1)} km away',
                                      ),
                                    ),
                                    trailing:
                                        const Icon(
                                      Icons
                                          .directions,
                                    ),
                                    onTap: () {
                                      Navigator.pop(
                                        context,
                                        place,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}