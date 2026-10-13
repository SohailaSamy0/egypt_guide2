import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:egypt_guide/core/localization/app_localizations.dart';

import 'package:egypt_guide/features/trips/data/models/trip.dart';
import 'package:egypt_guide/features/trips/data/services/trips_service.dart';
import 'package:egypt_guide/features/trips/presentation/screens/trip_details_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({
    super.key,
  });

  @override
  State<MyTripsScreen> createState() =>
      _MyTripsScreenState();
}

class _MyTripsScreenState
    extends State<MyTripsScreen> {
  final TripsService tripsService =
      TripsService();

  List<Trip> trips = [];

  bool isLoading = true;

  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    loadTrips();
  }

  List<Trip> get filteredTrips {
    if (selectedFilter == 'upcoming') {
      return trips
          .where(
            (trip) => !trip.isCompleted,
          )
          .toList();
    }

    if (selectedFilter == 'completed') {
      return trips
          .where(
            (trip) => trip.isCompleted,
          )
          .toList();
    }

    return trips;
  }

  // =========================================================
  // LOAD TRIPS
  // =========================================================

  Future<void> loadTrips() async {
    setState(() {
      isLoading = true;
    });

    final loadedTrips =
        await tripsService.getTrips();

    if (!mounted) return;

    setState(() {
      trips = loadedTrips;
      isLoading = false;
    });
  }

  // =========================================================
  // CREATE TRIP
  // =========================================================

  Future<void> createTrip() async {
    final trip =
        await showModalBottomSheet<Trip>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          const _TripFormSheet(),
    );

    if (trip == null) {
      return;
    }

    await tripsService.addTrip(
      trip,
    );

    await loadTrips();
  }

  // =========================================================
  // EDIT TRIP
  // =========================================================

  Future<void> editTrip(
    Trip trip,
  ) async {
    final updatedTrip =
        await showModalBottomSheet<Trip>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          _TripFormSheet(
        existingTrip: trip,
      ),
    );

    if (updatedTrip == null) {
      return;
    }

    await tripsService.updateTrip(
      updatedTrip,
    );

    await loadTrips();
  }

  // =========================================================
  // OPEN TRIP DETAILS
  // =========================================================

  Future<void> openTripDetails(
    Trip trip,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TripDetailsScreen(
          tripId: trip.id,
        ),
      ),
    );

    if (!mounted) return;

    await loadTrips();
  }

  // =========================================================
  // STATUS
  // =========================================================

  Future<void> toggleTripStatus(
    Trip trip,
  ) async {
    final updated =
        trip.copyWith(
      status: trip.isCompleted
          ? 'upcoming'
          : 'completed',
    );

    await tripsService.updateTrip(
      updated,
    );

    await loadTrips();
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteTrip(
    Trip trip,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Delete Trip',
          ),
          content: Text(
            'Are you sure you want to delete "${trip.title}"?',
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
                'DELETE',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await tripsService.deleteTrip(
      trip.id,
    );

    await loadTrips();
  }

  // =========================================================
  // FORMAT DATE
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

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final visibleTrips =
        filteredTrips;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Trips',
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: createTrip,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'NEW TRIP',
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadTrips,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  100,
                ),
                children: [
                  // ===========================================
                  // HEADER
                  // ===========================================

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
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 29,
                          backgroundColor:
                              Colors.white24,
                          child: Icon(
                            Icons
                                .luggage_outlined,
                            color:
                                Colors.white,
                            size: 31,
                          ),
                        ),

                        SizedBox(
                          width: 15,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Plan Your Egypt Journey',
                                style: TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 21,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              SizedBox(
                                height: 5,
                              ),

                              Text(
                                'Organize your trips and the places you want to visit.',
                                style: TextStyle(
                                  color:
                                      Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ===========================================
                  // FILTERS
                  // ===========================================

                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label:
                              const Text(
                            'All',
                          ),
                          selected:
                              selectedFilter ==
                                  'all',
                          onSelected: (_) {
                            setState(() {
                              selectedFilter =
                                  'all';
                            });
                          },
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        ChoiceChip(
                          label:
                              const Text(
                            'Upcoming',
                          ),
                          selected:
                              selectedFilter ==
                                  'upcoming',
                          onSelected: (_) {
                            setState(() {
                              selectedFilter =
                                  'upcoming';
                            });
                          },
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        ChoiceChip(
                          label:
                              const Text(
                            'Completed',
                          ),
                          selected:
                              selectedFilter ==
                                  'completed',
                          onSelected: (_) {
                            setState(() {
                              selectedFilter =
                                  'completed';
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ===========================================
                  // TITLE
                  // ===========================================

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your Trips',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        '${visibleTrips.length}',
                        style: TextStyle(
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ===========================================
                  // EMPTY
                  // ===========================================

                  if (visibleTrips.isEmpty)
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
                          color: colorScheme
                              .outlineVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons
                                .travel_explore_outlined,
                            size: 65,
                            color:
                                colorScheme.primary,
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          const Text(
                            'No trips yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            selectedFilter ==
                                    'all'
                                ? 'Create your first trip and start planning your journey.'
                                : 'There are no trips in this category.',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              color: colorScheme
                                  .onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),

                          if (selectedFilter ==
                              'all') ...[
                            const SizedBox(
                              height: 20,
                            ),

                            ElevatedButton.icon(
                              onPressed:
                                  createTrip,
                              icon:
                                  const Icon(
                                Icons.add,
                              ),
                              label:
                                  const Text(
                                'CREATE TRIP',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  // ===========================================
                  // TRIPS
                  // ===========================================

                  ...visibleTrips.map(
                    (trip) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: _TripCard(
                          trip: trip,
                          startDate:
                              formatDate(
                            trip.startDate,
                          ),
                          endDate:
                              formatDate(
                            trip.endDate,
                          ),
                          onTap: () {
                            openTripDetails(
                              trip,
                            );
                          },
                          onEdit: () {
                            editTrip(
                              trip,
                            );
                          },
                          onStatusChanged:
                              () {
                            toggleTripStatus(
                              trip,
                            );
                          },
                          onDelete: () {
                            deleteTrip(
                              trip,
                            );
                          },
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

// ===========================================================
// TRIP CARD
// ===========================================================

class _TripCard extends StatelessWidget {
  final Trip trip;

  final String startDate;
  final String endDate;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onStatusChanged;
  final VoidCallback onDelete;

  const _TripCard({
    required this.trip,
    required this.startDate,
    required this.endDate,
    required this.onTap,
    required this.onEdit,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      clipBehavior:
          Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color: trip.isCompleted
                      ? Colors.green
                          .withValues(
                            alpha: 0.12,
                          )
                      : colorScheme
                          .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: Icon(
                  trip.isCompleted
                      ? Icons
                          .check_circle_outline
                      : Icons
                          .flight_takeoff,
                  color: trip.isCompleted
                      ? Colors.green
                      : colorScheme.primary,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trip.title,
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        PopupMenuButton<String>(
                          onSelected:
                              (value) {
                            switch (value) {
                              case 'edit':
                                onEdit();
                                break;

                              case 'status':
                                onStatusChanged();
                                break;

                              case 'delete':
                                onDelete();
                                break;
                            }
                          },
                          itemBuilder:
                              (_) {
                            return [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .edit_outlined,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Edit Trip',
                                    ),
                                  ],
                                ),
                              ),

                              PopupMenuItem(
                                value:
                                    'status',
                                child: Row(
                                  children: [
                                    Icon(
                                      trip.isCompleted
                                          ? Icons
                                              .restart_alt
                                          : Icons
                                              .check_circle_outline,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      trip.isCompleted
                                          ? 'Mark Upcoming'
                                          : 'Mark Completed',
                                    ),
                                  ],
                                ),
                              ),

                              const PopupMenuDivider(),

                              const PopupMenuItem(
                                value:
                                    'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .delete_outline,
                                      color:
                                          Colors.red,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Delete Trip',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .location_on_outlined,
                          size: 16,
                          color: colorScheme
                              .onSurfaceVariant,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Expanded(
                          child: Text(
                            trip.destination,
                            style: TextStyle(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .calendar_month_outlined,
                          size: 16,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Expanded(
                          child: Text(
                            '$startDate  →  $endDate',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: trip.isCompleted
                                ? Colors.green
                                    .withValues(
                                      alpha:
                                          0.12,
                                    )
                                : colorScheme
                                    .primaryContainer,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            trip.isCompleted
                                ? 'Completed'
                                : 'Upcoming',
                            style:
                                TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                              color: trip.isCompleted
                                  ? Colors.green
                                  : colorScheme
                                      .primary,
                            ),
                          ),
                        ),

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
                                .surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons
                                    .place_outlined,
                                size: 14,
                              ),

                              const SizedBox(
                                width: 4,
                              ),

                              Text(
                                '${trip.places.length} places',
                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (trip.notes
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        trip.notes,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme
                              .onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Tap to view trip plan',
                      style: TextStyle(
                        color: colorScheme
                            .primary,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// TRIP FORM
// ===========================================================

class _TripFormSheet
    extends StatefulWidget {
  final Trip? existingTrip;

  const _TripFormSheet({
    this.existingTrip,
  });

  @override
  State<_TripFormSheet>
      createState() =>
          _TripFormSheetState();
}

class _TripFormSheetState
    extends State<_TripFormSheet> {
  final formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      titleController;

  late final TextEditingController
      destinationController;

  late final TextEditingController
      notesController;

  late DateTime startDate;

  late DateTime endDate;

  bool get isEditing =>
      widget.existingTrip != null;

  @override
  void initState() {
    super.initState();

    final trip =
        widget.existingTrip;

    titleController =
        TextEditingController(
      text: trip?.title ?? '',
    );

    destinationController =
        TextEditingController(
      text: trip?.destination ?? '',
    );

    notesController =
        TextEditingController(
      text: trip?.notes ?? '',
    );

    startDate =
        trip?.startDate ??
            DateTime.now();

    endDate =
        trip?.endDate ??
            DateTime.now().add(
              const Duration(
                days: 1,
              ),
            );
  }

  @override
  void dispose() {
    titleController.dispose();

    destinationController.dispose();

    notesController.dispose();

    super.dispose();
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

  Future<void> pickStartDate() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate:
          DateTime.now().subtract(
        const Duration(
          days: 365,
        ),
      ),
      lastDate:
          DateTime.now().add(
        const Duration(
          days: 3650,
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      startDate = selected;

      if (endDate.isBefore(
        startDate,
      )) {
        endDate =
            startDate.add(
          const Duration(
            days: 1,
          ),
        );
      }
    });
  }

  Future<void> pickEndDate() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          endDate.isBefore(startDate)
              ? startDate
              : endDate,
      firstDate: startDate,
      lastDate:
          DateTime.now().add(
        const Duration(
          days: 3650,
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      endDate = selected;
    });
  }

  void saveTrip() {
    if (!(formKey.currentState
            ?.validate() ??
        false)) {
      return;
    }

    if (endDate.isBefore(
      startDate,
    )) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'End date cannot be before start date.',
          ),
        ),
      );

      return;
    }

    final existing =
        widget.existingTrip;

    final trip = Trip(
      id: existing?.id ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      title:
          titleController.text.trim(),
      destination:
          destinationController.text
              .trim(),
      startDate: startDate,
      endDate: endDate,
      status:
          existing?.status ??
              'upcoming',
      notes:
          notesController.text.trim(),

      // مهم جدًا عشان الـ Edit ما يمسحش الأماكن.
      places:
          existing?.places ?? const [],
    );

    Navigator.pop(
      context,
      trip,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom:
            MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                25,
      ),
      child:
          SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                isEditing
                    ? 'Edit Trip'
                    : 'Create New Trip',
                style:
                    const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller:
                    titleController,
                textCapitalization:
                    TextCapitalization.words,
                decoration:
                    InputDecoration(
                  labelText:
                      context.trLiteral('Trip Name'),
                  hintText:
                      context.trLiteral('Alexandria Weekend'),
                  prefixIcon:
                      Icon(
                    Icons.luggage_outlined,
                  ),
                ),
                validator:
                    (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return context.trLiteral('Enter a trip name.');
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 14,
              ),

              TextFormField(
                controller:
                    destinationController,
                textCapitalization:
                    TextCapitalization.words,
                decoration:
                    InputDecoration(
                  labelText:
                      context.trLiteral('Destination'),
                  hintText:
                      context.trLiteral('Alexandria'),
                  prefixIcon:
                      Icon(
                    Icons
                        .location_on_outlined,
                  ),
                ),
                validator:
                    (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return context.trLiteral('Enter a destination.');
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 18,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _DateBox(
                      title: 'Start',
                      date:
                          formatDate(
                        startDate,
                      ),
                      icon: Icons
                          .flight_takeoff,
                      onTap:
                          pickStartDate,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        _DateBox(
                      title: 'End',
                      date:
                          formatDate(
                        endDate,
                      ),
                      icon:
                          Icons.flight_land,
                      onTap:
                          pickEndDate,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    notesController,
                minLines: 3,
                maxLines: 5,
                decoration:
                    InputDecoration(
                  labelText:
                      context.trLiteral('Notes (Optional)'),
                  hintText:
                      context.trLiteral('Places to visit, hotel, plans...'),
                  alignLabelWithHint:
                      true,
                  prefixIcon:
                      Icon(
                    Icons.notes_outlined,
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      saveTrip,
                  icon:
                      const Icon(
                    Icons.save_outlined,
                  ),
                  label: Text(
                    isEditing
                        ? 'SAVE CHANGES'
                        : 'CREATE TRIP',
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Center(
                child: Text(
                  'Trips are currently saved locally on this device.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// DATE BOX
// ===========================================================

class _DateBox
    extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final VoidCallback onTap;

  const _DateBox({
    required this.title,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          15,
        ),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.all(
            13,
          ),
          decoration:
              BoxDecoration(
            border: Border.all(
              color: colorScheme
                  .outlineVariant,
            ),
            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 17,
                    color:
                        colorScheme.primary,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                date,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}