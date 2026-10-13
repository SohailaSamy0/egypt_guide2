import 'package:flutter/material.dart' hide Text;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:egypt_guide/core/localization/app_localizations.dart';

import 'package:egypt_guide/features/home/data/models/nearby_place.dart';
import 'package:egypt_guide/features/home/data/models/place_search_result.dart';
import 'package:egypt_guide/features/home/data/models/route_result.dart';

import 'package:egypt_guide/features/home/data/services/nearby_places_service.dart';
import 'package:egypt_guide/features/home/data/services/place_search_service.dart';
import 'package:egypt_guide/features/home/data/services/route_service.dart';

import 'package:egypt_guide/features/home/presentation/screens/favorites_screen.dart';
import 'package:egypt_guide/features/home/presentation/screens/place_details_screen.dart';
import 'package:egypt_guide/features/home/presentation/screens/recommendations_screen.dart';
import 'package:egypt_guide/features/home/presentation/screens/transport_options_screen.dart';

import 'package:egypt_guide/features/profile/presentation/screens/profile_screen.dart';
import 'package:egypt_guide/features/safety/presentation/screens/safety_center_screen.dart';

class HomeScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const HomeScreen({
    super.key,
    this.latitude,
    this.longitude,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController mapController = MapController();

  final TextEditingController searchController =
      TextEditingController();

  final PlaceSearchService searchService =
      PlaceSearchService();

  final NearbyPlacesService nearbyPlacesService =
      NearbyPlacesService();

  final RouteService routeService =
      RouteService();

  static const LatLng cairoLocation = LatLng(
    30.0444,
    31.2357,
  );

  final List<String> categories = [
    'Restaurants',
    'Cafes',
    'Attractions',
    'Museums',
    'Hotels',
  ];

  List<PlaceSearchResult> searchResults = [];

  List<NearbyPlace> nearbyPlaces = [];

  PlaceSearchResult? selectedSearchPlace;

  NearbyPlace? selectedNearbyPlace;

  RouteResult? activeRoute;

  String? selectedCategory;

  bool isSearching = false;

  bool isLoadingNearby = false;

  bool isLoadingRoute = false;

  LatLng get currentLocation {
    if (widget.latitude != null &&
        widget.longitude != null) {
      return LatLng(
        widget.latitude!,
        widget.longitude!,
      );
    }

    return cairoLocation;
  }

  // =========================================================
  // CATEGORY TEXT
  // =========================================================

  String categoryText(
    BuildContext context,
    String category,
  ) {
    switch (category) {
      case 'Restaurants':
        return context.tr('restaurants');

      case 'Cafes':
        return context.tr('cafes');

      case 'Attractions':
        return context.tr('attractions');

      case 'Museums':
        return context.tr('museums');

      case 'Hotels':
        return context.tr('hotels');

      case 'history':
        return context.tr('history');

      case 'museums':
        return context.tr('museums');

      case 'food':
        return context.tr('food');

      case 'beaches':
        return context.tr('beaches');

      case 'shopping':
        return context.tr('shopping');

      case 'adventure':
        return context.tr('adventure');

      case 'ancient_egypt':
        return context.tr('ancient_egypt');

      case 'culture':
        return context.tr('culture');

      case 'nature':
        return context.tr('nature');

      case 'nightlife':
        return context.tr('nightlife');

      case 'Hospital':
        return context.tr('hospital');

      case 'Pharmacy':
        return context.tr('pharmacy');

      case 'Police':
        return context.tr('police');

      default:
        return category;
    }
  }

  // =========================================================
  // CATEGORY ICON
  // =========================================================

  IconData categoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Restaurants':
        return Icons.restaurant_outlined;

      case 'Cafes':
        return Icons.local_cafe_outlined;

      case 'Attractions':
        return Icons.camera_alt_outlined;

      case 'Museums':
        return Icons.museum_outlined;

      case 'Hotels':
        return Icons.hotel_outlined;

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

  // =========================================================
  // SEARCH
  // =========================================================

  Future<void> searchPlaces() async {
    final query =
        searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSearching = true;

      searchResults = [];

      activeRoute = null;
    });

    try {
      final results =
          await searchService.searchPlaces(
        query,
      );

      if (!mounted) return;

      setState(() {
        searchResults = results;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'no_places_found',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not search places. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  void selectSearchPlace(
    PlaceSearchResult place,
  ) {
    setState(() {
      selectedSearchPlace = place;

      selectedNearbyPlace = null;

      activeRoute = null;

      searchResults = [];

      searchController.text =
          place.displayName;
    });

    mapController.move(
      LatLng(
        place.latitude,
        place.longitude,
      ),
      16,
    );
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      searchResults = [];

      selectedSearchPlace = null;
    });
  }

  // =========================================================
  // NEARBY PLACES
  // =========================================================

  Future<void> loadNearbyPlaces(
    String category,
  ) async {
    if (widget.latitude == null ||
        widget.longitude == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enable your location first.',
          ),
        ),
      );

      return;
    }

    setState(() {
      selectedCategory = category;

      isLoadingNearby = true;

      nearbyPlaces = [];

      selectedNearbyPlace = null;

      activeRoute = null;
    });

    try {
      final places =
          await nearbyPlacesService
              .getNearbyPlaces(
        latitude: widget.latitude!,
        longitude: widget.longitude!,
        category: category,
      );

      if (!mounted) return;

      setState(() {
        nearbyPlaces = places;
      });

      if (places.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'No nearby $category found.',
            ),
          ),
        );

        return;
      }

      mapController.move(
        LatLng(
          widget.latitude!,
          widget.longitude!,
        ),
        14,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not load nearby places. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingNearby = false;
        });
      }
    }
  }

  // =========================================================
  // SELECT NEARBY PLACE
  // =========================================================

  void selectNearbyPlace(
    NearbyPlace place,
  ) {
    setState(() {
      selectedNearbyPlace = place;

      selectedSearchPlace = null;
    });

    mapController.move(
      LatLng(
        place.latitude,
        place.longitude,
      ),
      17,
    );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (
        bottomSheetContext,
      ) {
        return Padding(
          padding:
              const EdgeInsets.all(
            22,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration:
                        BoxDecoration(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primaryContainer,
                      shape:
                          BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIcon(
                        place.category,
                      ),
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary,
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
                          place.name,
                          style:
                              const TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          categoryText(
                            context,
                            place.category,
                          ),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 22,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 48,
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      bottomSheetContext,
                    );

                    openPlaceDetails(
                      place,
                    );
                  },
                  icon: const Icon(
                    Icons.info_outline,
                  ),
                  label: const Text(
                    'VIEW PLACE DETAILS',
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 48,
                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      bottomSheetContext,
                    );

                    getDirections(
                      place,
                    );
                  },
                  icon: const Icon(
                    Icons.directions,
                  ),
                  label: const Text(
                    'GET DIRECTIONS',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // PLACE DETAILS
  // =========================================================

  Future<void> openPlaceDetails(
    NearbyPlace place,
  ) async {
    final result =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PlaceDetailsScreen(
          place: place,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await getDirections(
        place,
      );
    }
  }

  // =========================================================
  // ROUTE
  // =========================================================

  Future<void> getDirections(
    NearbyPlace place,
  ) async {
    if (widget.latitude == null ||
        widget.longitude == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Current location is not available.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoadingRoute = true;

      activeRoute = null;

      selectedNearbyPlace = place;

      selectedSearchPlace = null;
    });

    try {
      final result =
          await routeService
              .getDrivingRoute(
        startLatitude:
            widget.latitude!,
        startLongitude:
            widget.longitude!,
        endLatitude:
            place.latitude,
        endLongitude:
            place.longitude,
      );

      if (!mounted) return;

      setState(() {
        activeRoute = result;
      });

      final middleLatitude =
          (widget.latitude! +
                  place.latitude) /
              2;

      final middleLongitude =
          (widget.longitude! +
                  place.longitude) /
              2;

      final zoom =
          getRouteZoom(
        result.distanceKm,
      );

      mapController.move(
        LatLng(
          middleLatitude,
          middleLongitude,
        ),
        zoom,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not calculate route. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingRoute = false;
        });
      }
    }
  }

  double getRouteZoom(
    double distanceKm,
  ) {
    if (distanceKm < 1) {
      return 15.5;
    }

    if (distanceKm < 3) {
      return 14.5;
    }

    if (distanceKm < 7) {
      return 13.5;
    }

    if (distanceKm < 15) {
      return 12.5;
    }

    return 11.5;
  }

  void clearRoute() {
    setState(() {
      activeRoute = null;

      selectedNearbyPlace = null;
    });

    goToCurrentLocation();
  }

  // =========================================================
  // CURRENT LOCATION
  // =========================================================

  void goToCurrentLocation() {
    if (widget.latitude == null ||
        widget.longitude == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Location is not available.',
          ),
        ),
      );

      return;
    }

    mapController.move(
      LatLng(
        widget.latitude!,
        widget.longitude!,
      ),
      16,
    );
  }

  // =========================================================
  // PROFILE
  // =========================================================

  String get profileInitials {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim() ?? '';

    if (name.isNotEmpty) {
      final parts = name
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }

      return parts.first[0].toUpperCase();
    }

    final email = user?.email?.trim() ?? '';
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }

    return 'U';
  }

  Future<void> openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // SAFETY CENTER
  // =========================================================

  Future<void> openSafetyCenter() async {
    final place =
        await Navigator.push<NearbyPlace>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SafetyCenterScreen(
          latitude:
              widget.latitude,
          longitude:
              widget.longitude,
        ),
      ),
    );

    if (!mounted) return;

    if (place != null) {
      await getDirections(
        place,
      );
    }
  }

  // =========================================================
  // RECOMMENDATIONS
  // =========================================================

  Future<void> openRecommendations() async {
    final place =
        await Navigator.push<NearbyPlace>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RecommendationsScreen(
          latitude:
              widget.latitude,
          longitude:
              widget.longitude,
        ),
      ),
    );

    if (!mounted) return;

    if (place != null) {
      await getDirections(
        place,
      );
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    searchController.dispose();

    mapController.dispose();

    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final surfaceColor =
        Theme.of(context)
            .colorScheme
            .surface;

    final primaryColor =
        Theme.of(context)
            .colorScheme
            .primary;

    final bool routeIsVisible =
        activeRoute != null ||
            isLoadingRoute;

    return Scaffold(
      body: Stack(
        children: [
          // ===================================================
          // MAP
          // ===================================================

          FlutterMap(
            mapController:
                mapController,
            options:
                MapOptions(
              initialCenter:
                  currentLocation,
              initialZoom:
                  widget.latitude !=
                          null
                      ? 15
                      : 11,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'egypt_guide',
                maxNativeZoom: 19,
              ),

              // ROUTE
              if (activeRoute !=
                  null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points:
                          activeRoute!
                              .points,
                      strokeWidth: 6,
                      color:
                          primaryColor,
                    ),
                  ],
                ),

              // MARKERS
              MarkerLayer(
                markers: [
                  // Current Location
                  if (widget.latitude !=
                          null &&
                      widget.longitude !=
                          null)
                    Marker(
                      point:
                          LatLng(
                        widget.latitude!,
                        widget.longitude!,
                      ),
                      width: 55,
                      height: 55,
                      child:
                          const Icon(
                        Icons.location_pin,
                        size: 50,
                        color:
                            Colors.red,
                      ),
                    ),

                  // Search Result
                  if (selectedSearchPlace !=
                      null)
                    Marker(
                      point:
                          LatLng(
                        selectedSearchPlace!
                            .latitude,
                        selectedSearchPlace!
                            .longitude,
                      ),
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.place,
                        size: 52,
                        color:
                            primaryColor,
                      ),
                    ),

                  // Nearby Places
                  ...nearbyPlaces.map(
                    (
                      place,
                    ) {
                      return Marker(
                        point:
                            LatLng(
                          place.latitude,
                          place.longitude,
                        ),
                        width: 45,
                        height: 45,
                        child:
                            GestureDetector(
                          onTap: () {
                            selectNearbyPlace(
                              place,
                            );
                          },
                          child:
                              Icon(
                            categoryIcon(
                              place.category,
                            ),
                            size: 35,
                            color:
                                primaryColor,
                          ),
                        ),
                      );
                    },
                  ),

                  // Safety / Recommendation Destination
                  if (selectedNearbyPlace !=
                          null &&
                      !nearbyPlaces.any(
                        (
                          place,
                        ) =>
                            place.id ==
                            selectedNearbyPlace!
                                .id,
                      ))
                    Marker(
                      point:
                          LatLng(
                        selectedNearbyPlace!
                            .latitude,
                        selectedNearbyPlace!
                            .longitude,
                      ),
                      width: 50,
                      height: 50,
                      child:
                          GestureDetector(
                        onTap: () {
                          selectNearbyPlace(
                            selectedNearbyPlace!,
                          );
                        },
                        child: Icon(
                          categoryIcon(
                            selectedNearbyPlace!
                                .category,
                          ),
                          size: 40,
                          color:
                              primaryColor,
                        ),
                      ),
                    ),
                ],
              ),

              const SimpleAttributionWidget(
                source: Text(
                  'OpenStreetMap contributors',
                ),
              ),
            ],
          ),

          // ===================================================
          // TOP SEARCH + PROFILE
          // ===================================================

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                15,
                16,
                0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            Container(
                          height: 56,
                          decoration:
                              BoxDecoration(
                            color:
                                surfaceColor,
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
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
                                  3,
                                ),
                              ),
                            ],
                          ),
                          child:
                              TextField(
                            controller:
                                searchController,
                            textInputAction:
                                TextInputAction
                                    .search,
                            onSubmitted:
                                (_) {
                              searchPlaces();
                            },
                            onChanged:
                                (_) {
                              setState(
                                () {},
                              );
                            },
                            decoration:
                                InputDecoration(
                              filled:
                                  false,
                              hintText:
                                  context.tr('search_places'),
                              prefixIcon:
                                  Icon(
                                Icons.search,
                                color:
                                    primaryColor,
                              ),
                              suffixIcon:
                                  searchController
                                          .text
                                          .isNotEmpty
                                      ? IconButton(
                                          onPressed:
                                              clearSearch,
                                          icon:
                                              const Icon(
                                            Icons.close,
                                          ),
                                        )
                                      : null,
                              border:
                                  InputBorder
                                      .none,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =================================================
                  // CATEGORIES
                  // =================================================

                  SizedBox(
                    height: 45,
                    child:
                        ListView.separated(
                      scrollDirection:
                          Axis.horizontal,
                      itemCount:
                          categories.length,
                      separatorBuilder:
                          (
                        context,
                        index,
                      ) =>
                              const SizedBox(
                        width: 8,
                      ),
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final category =
                            categories[
                                index];

                        final selected =
                            selectedCategory ==
                                category;

                        return ChoiceChip(
                          selected:
                              selected,
                          onSelected:
                              (_) {
                            loadNearbyPlaces(
                              category,
                            );
                          },
                          avatar:
                              Icon(
                            categoryIcon(
                              category,
                            ),
                            size: 18,
                          ),
                          label:
                              Text(
                            categoryText(
                              context,
                              category,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // =================================================
                  // NEARBY LOADING
                  // =================================================

                  if (isLoadingNearby)
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        top: 10,
                      ),
                      child:
                          LinearProgressIndicator(),
                    ),

                  // =================================================
                  // SEARCH LOADING
                  // =================================================

                  if (isSearching)
                    Container(
                      margin:
                          const EdgeInsets.only(
                        top: 8,
                      ),
                      padding:
                          const EdgeInsets.all(
                        14,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            surfaceColor,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      child:
                          const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                        ),
                      ),
                    ),

                  // =================================================
                  // SEARCH RESULTS
                  // =================================================

                  if (searchResults
                      .isNotEmpty)
                    Container(
                      margin:
                          const EdgeInsets.only(
                        top: 8,
                      ),
                      constraints:
                          const BoxConstraints(
                        maxHeight:
                            280,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            surfaceColor,
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                      child:
                          ListView.separated(
                        shrinkWrap:
                            true,
                        itemCount:
                            searchResults
                                .length,
                        separatorBuilder:
                            (
                          context,
                          index,
                        ) =>
                                const Divider(
                          height: 1,
                        ),
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final place =
                              searchResults[
                                  index];

                          return ListTile(
                            leading:
                                Icon(
                              Icons
                                  .place_outlined,
                              color:
                                  primaryColor,
                            ),
                            title:
                                Text(
                              place
                                  .displayName,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                            onTap:
                                () {
                              selectSearchPlace(
                                place,
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ===================================================
          // ROUTE CARD
          // ===================================================

          if (routeIsVisible)
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: 100,
              child: Material(
                color:
                    surfaceColor,
                elevation: 8,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child:
                      isLoadingRoute
                          ? const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  'Calculating route...',
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        primaryColor
                                            .withValues(
                                      alpha:
                                          0.12,
                                    ),
                                    shape:
                                        BoxShape.circle,
                                  ),
                                  child:
                                      Icon(
                                    Icons
                                        .directions_car,
                                    color:
                                        primaryColor,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        selectedNearbyPlace
                                                ?.name ??
                                            'Destination',
                                        maxLines:
                                            1,
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

                                      const SizedBox(
                                        height: 5,
                                      ),

                                      Text(
                                        '${activeRoute!.distanceKm.toStringAsFixed(1)} km'
                                        '  •  '
                                        '${activeRoute!.durationMinutes.round()} min',
                                      ),

                                      const SizedBox(
                                        height: 8,
                                      ),

                                      TextButton.icon(
                                        onPressed:
                                            () {
                                          if (selectedNearbyPlace ==
                                                  null ||
                                              activeRoute ==
                                                  null) {
                                            return;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  TransportOptionsScreen(
                                                destinationName:
                                                    selectedNearbyPlace!
                                                        .name,
                                                distanceKm:
                                                    activeRoute!
                                                        .distanceKm,
                                                drivingMinutes:
                                                    activeRoute!
                                                        .durationMinutes,
                                              ),
                                            ),
                                          );
                                        },
                                        icon:
                                            const Icon(
                                          Icons
                                              .directions_transit,
                                          size:
                                              18,
                                        ),
                                        label:
                                            const Text(
                                          'TRANSPORT OPTIONS',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed:
                                      clearRoute,
                                  icon:
                                      const Icon(
                                    Icons.close,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),

          // ===================================================
          // FAVORITES
          // ===================================================

          PositionedDirectional(
            start: 18,
            bottom:
                routeIsVisible
                    ? 250
                    : 100,
            child:
                FloatingActionButton.small(
              heroTag:
                  'favorites_button',
              tooltip:
                  'Favorites',
              onPressed:
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            const FavoritesScreen(),
                  ),
                );
              },
              backgroundColor:
                  surfaceColor,
              foregroundColor:
                  Colors.red,
              child:
                  const Icon(
                Icons.favorite,
              ),
            ),
          ),

          // ===================================================
          // SAFETY
          // ===================================================

          PositionedDirectional(
            end: 18,
            bottom:
                routeIsVisible
                    ? 250
                    : 100,
            child:
                FloatingActionButton.small(
              heroTag:
                  'safety_button',
              tooltip:
                  'Safety Center',
              onPressed:
                  openSafetyCenter,
              backgroundColor:
                  surfaceColor,
              foregroundColor:
                  Colors.redAccent,
              child:
                  const Icon(
                Icons
                    .health_and_safety,
              ),
            ),
          ),

          // ===================================================
          // FOR YOU
          // ===================================================

          PositionedDirectional(
            start: 90,
            end: 90,
            bottom: 30,
            child: SizedBox(
              height: 50,
              child:
                  ElevatedButton.icon(
                onPressed:
                    openRecommendations,
                icon:
                    const Icon(
                  Icons.auto_awesome,
                  size: 19,
                ),
                label:
                    const Text(
                  'FOR YOU',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  elevation: 6,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      25,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ===================================================
          // PROFILE
          // ===================================================

          PositionedDirectional(
            start: 18,
            bottom: 30,
            child: FloatingActionButton(
              heroTag: 'profile_button_bottom',
              tooltip: context.tr('profile'),
              onPressed: openProfile,
              backgroundColor: surfaceColor,
              foregroundColor: primaryColor,
              child: Text(
                profileInitials,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          // ===================================================
          // CURRENT LOCATION
          // ===================================================

          PositionedDirectional(
            end: 18,
            bottom: 30,
            child:
                FloatingActionButton(
              heroTag:
                  'current_location_button',
              tooltip:
                  'My Location',
              onPressed:
                  goToCurrentLocation,
              backgroundColor:
                  surfaceColor,
              foregroundColor:
                  primaryColor,
              child:
                  const Icon(
                Icons.my_location,
              ),
            ),
          ),
        ],
      ),
    );
  }
}