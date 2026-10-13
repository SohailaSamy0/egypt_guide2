import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/features/home/data/models/nearby_place.dart';
import 'package:egypt_guide/features/home/data/services/favorites_service.dart';
import 'package:egypt_guide/features/trips/presentation/screens/add_to_trip_screen.dart';

class PlaceDetailsScreen
    extends StatefulWidget {
  final NearbyPlace place;

  const PlaceDetailsScreen({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailsScreen> createState() =>
      _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState
    extends State<PlaceDetailsScreen> {
  final FavoritesService favoritesService =
      FavoritesService();

  bool isFavorite = false;
  bool isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();

    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final favorite =
        await favoritesService.isFavorite(
      widget.place.id,
    );

    if (!mounted) return;

    setState(() {
      isFavorite = favorite;
      isLoadingFavorite = false;
    });
  }

  Future<void> toggleFavorite() async {
  await favoritesService.toggleFavorite(
    widget.place,
  );

  if (!mounted) return;

  setState(() {
    isFavorite = !isFavorite;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isFavorite
            ? 'Added to favorites.'
            : 'Removed from favorites.',
      ),
    ),
  );
}

  Future<void> addToTrip() async {
    final added =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddToTripScreen(
          place: widget.place,
        ),
      ),
    );

    if (!mounted) return;

    if (added == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Place added to your trip.',
          ),
        ),
      );
    }
  }

  IconData getPlaceIcon() {
    switch (widget.place.category) {
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
          'Place Details',
        ),
        actions: [
          if (!isLoadingFavorite)
            IconButton(
              tooltip:
                  'Favorite',
              onPressed:
                  toggleFavorite,
              icon: Icon(
                isFavorite
                    ? Icons.favorite
                    : Icons
                        .favorite_border,
                color: isFavorite
                    ? Colors.red
                    : null,
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 600,
          ),
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.all(
              22,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 105,
                    height: 105,
                    decoration:
                        BoxDecoration(
                      color: colorScheme
                          .primaryContainer,
                      shape:
                          BoxShape.circle,
                    ),
                    child: Icon(
                      getPlaceIcon(),
                      size: 52,
                      color:
                          colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                Center(
                  child: Text(
                    widget.place.name,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Center(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                      widget
                          .place.category,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                const Text(
                  'Location',
                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                _InfoTile(
                  icon: Icons
                      .location_on_outlined,
                  title:
                      'Coordinates',
                  value:
                      '${widget.place.latitude.toStringAsFixed(5)}, '
                      '${widget.place.longitude.toStringAsFixed(5)}',
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    icon:
                        const Icon(
                      Icons.directions,
                    ),
                    label:
                        const Text(
                      'GET DIRECTIONS',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        addToTrip,
                    icon:
                        const Icon(
                      Icons
                          .playlist_add,
                    ),
                    label:
                        const Text(
                      'ADD TO TRIP',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        isLoadingFavorite
                            ? null
                            : toggleFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons
                              .favorite_border,
                      color:
                          isFavorite
                              ? Colors.red
                              : null,
                    ),
                    label: Text(
                      isFavorite
                          ? 'REMOVE FROM FAVORITES'
                          : 'ADD TO FAVORITES',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
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
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: colorScheme
              .outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                colorScheme.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(
                    fontSize: 12,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}