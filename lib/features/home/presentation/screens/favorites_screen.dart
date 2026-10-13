import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/features/home/data/models/favorite_place.dart';
import 'package:egypt_guide/features/home/data/models/nearby_place.dart';
import 'package:egypt_guide/features/home/data/services/favorites_service.dart';
import 'package:egypt_guide/features/home/presentation/screens/place_details_screen.dart';

class FavoritesScreen
    extends StatefulWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  State<FavoritesScreen>
      createState() =>
          _FavoritesScreenState();
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {
  final FavoritesService
      favoritesService =
      FavoritesService();

  List<FavoritePlace> favorites = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final result =
        await favoritesService
            .getFavorites();

    if (!mounted) return;

    setState(() {
      favorites = result;
      isLoading = false;
    });
  }

  Future<void> removeFavorite(
    int id,
  ) async {
    await favoritesService
        .removeFavorite(id);

    await loadFavorites();
  }

  NearbyPlace toNearbyPlace(
    FavoritePlace place,
  ) {
    return NearbyPlace(
      id: place.id,
      name: place.name,
      latitude:
          place.latitude,
      longitude:
          place.longitude,
      category:
          place.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Favorites',
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize
                            .min,
                    children: [
                      Icon(
                        Icons
                            .favorite_border,
                        size: 70,
                        color:
                            Colors.grey,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'No favorite places yet.',
                        style:
                            TextStyle(
                          fontSize:
                              18,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets
                          .all(
                    18,
                  ),
                  itemCount:
                      favorites.length,
                  separatorBuilder:
                      (
                    context,
                    index,
                  ) =>
                          const SizedBox(
                    height: 10,
                  ),
                  itemBuilder:
                      (
                    context,
                    index,
                  ) {
                    final place =
                        favorites[
                            index];

                    return Card(
                      child:
                          ListTile(
                        leading:
                            const CircleAvatar(
                          child: Icon(
                            Icons
                                .place_outlined,
                          ),
                        ),
                        title: Text(
                          place.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                        subtitle:
                            Text(
                          place
                              .category,
                        ),
                        trailing:
                            IconButton(
                          onPressed:
                              () {
                            removeFavorite(
                              place.id,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .favorite,
                            color:
                                Colors.red,
                          ),
                        ),
                        onTap:
                            () async {
                          await Navigator
                              .push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlaceDetailsScreen(
                                place:
                                    toNearbyPlace(
                                  place,
                                ),
                              ),
                            ),
                          );

                          loadFavorites();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}