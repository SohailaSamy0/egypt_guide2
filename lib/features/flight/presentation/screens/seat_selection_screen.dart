import 'package:flutter/material.dart' hide Text;

import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:egypt_guide/core/widgets/aviation_background.dart';
import 'package:egypt_guide/features/flight/data/models/flight_offer.dart';
import 'package:egypt_guide/features/flight/data/models/flight_seat.dart';
import 'package:egypt_guide/features/flight/data/services/flight_service.dart';
import 'package:egypt_guide/features/flight/presentation/screens/passenger_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final FlightOffer offer;
  final int travelers;
  final String travelClass;

  const SeatSelectionScreen({
    super.key,
    required this.offer,
    required this.travelers,
    required this.travelClass,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final FlightService flightService = FlightService();

  bool loading = true;
  String? errorMessage;
  List<FlightSeat> seats = const [];
  final Map<String, SelectedFlightSeat> selectedByPassenger = {};
  int activePassengerIndex = 0;

  List<String> get passengerIds => widget.offer.passengerIds;

  @override
  void initState() {
    super.initState();
    loadSeats();
  }

  Future<void> loadSeats() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await flightService.getSeatMap(widget.offer.id);
      if (!mounted) return;
      setState(() => seats = result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  bool get hasPassengerIds => passengerIds.length >= widget.travelers;

  String get activePassengerId {
    if (!hasPassengerIds) return '';
    return passengerIds[activePassengerIndex];
  }

  void selectSeat(FlightSeat seat) {
    if (!hasPassengerIds || !seat.available) return;

    final passengerId = activePassengerId;
    final service = seat.serviceForPassenger(passengerId);

    if (service == null || service.serviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This seat is not available for this passenger.'),
        ),
      );
      return;
    }

    final alreadyUsed = selectedByPassenger.entries.any(
      (entry) =>
          entry.key != passengerId && entry.value.designator == seat.designator,
    );

    if (alreadyUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This seat is already selected.')),
      );
      return;
    }

    setState(() {
      selectedByPassenger[passengerId] = SelectedFlightSeat(
        passengerId: passengerId,
        designator: seat.designator,
        serviceId: service.serviceId,
        amount: service.amount,
        currency: service.currency,
      );

      if (activePassengerIndex < widget.travelers - 1) {
        activePassengerIndex++;
      }
    });
  }

  void continueNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PassengerDetailsScreen(
          offer: widget.offer,
          selectedSeats: selectedByPassenger.values.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedCount = selectedByPassenger.length;

    return Scaffold(
      body: AviationBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Seat',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${widget.offer.airlineName} • ${widget.offer.origin} → ${widget.offer.destination}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasPassengerIds && widget.travelers > 1)
                    SizedBox(
                      height: 54,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: widget.travelers,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final passengerId = passengerIds[index];
                          final selected = selectedByPassenger[passengerId];
                          return ChoiceChip(
                            selected: activePassengerIndex == index,
                            onSelected: (_) =>
                                setState(() => activePassengerIndex = index),
                            label: Text(
                              selected == null
                                  ? 'Passenger ${index + 1}'
                                  : 'Passenger ${index + 1} • ${selected.designator}',
                            ),
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage != null
                            ? _SeatMessage(
                                icon: Icons.error_outline_rounded,
                                title: 'Could not load seats',
                                message: errorMessage!,
                                buttonText: 'TRY AGAIN',
                                onPressed: loadSeats,
                              )
                            : !hasPassengerIds
                                ? _SeatMessage(
                                    icon: Icons.person_off_outlined,
                                    title: 'Passenger data is unavailable',
                                    message:
                                        'Search for the flight again before selecting seats.',
                                    buttonText: 'BACK',
                                    onPressed: () => Navigator.pop(context),
                                  )
                                : seats.isEmpty
                                    ? _SeatMessage(
                                        icon: Icons.airline_seat_recline_normal,
                                        title: 'Seat map not available',
                                        message:
                                            'This airline does not provide a seat map for this offer. You can continue and the airline may assign seats later.',
                                        buttonText: 'CONTINUE WITHOUT SEAT',
                                        onPressed: continueNext,
                                      )
                                    : GridView.builder(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          24,
                                        ),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1.2,
                                        ),
                                        itemCount: seats.length,
                                        itemBuilder: (context, index) {
                                          final seat = seats[index];
                                          final service = seat.serviceForPassenger(
                                            activePassengerId,
                                          );
                                          final selected = selectedByPassenger.values
                                              .any(
                                            (value) =>
                                                value.designator == seat.designator,
                                          );
                                          final available = seat.available && service != null;

                                          return InkWell(
                                            onTap: available
                                                ? () => selectSeat(seat)
                                                : null,
                                            borderRadius: BorderRadius.circular(14),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: selected
                                                    ? colors.primary
                                                    : available
                                                        ? colors.surface
                                                        : colors.surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: selected
                                                      ? colors.primary
                                                      : colors.outlineVariant,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.event_seat_rounded,
                                                    color: selected
                                                        ? colors.onPrimary
                                                        : available
                                                            ? colors.primary
                                                            : colors.outline,
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    seat.designator,
                                                    style: TextStyle(
                                                      color: selected
                                                          ? colors.onPrimary
                                                          : colors.onSurface,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                  if (available &&
                                                      service.amount > 0)
                                                    Text(
                                                      '+${service.amount.toStringAsFixed(0)} ${service.currency}',
                                                      style: TextStyle(
                                                        color: selected
                                                            ? colors.onPrimary
                                                            : colors.onSurfaceVariant,
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                  ),
                  if (!loading &&
                      errorMessage == null &&
                      hasPassengerIds &&
                      seats.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.93),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('$selectedCount/${widget.travelers} seats'),
                              const Spacer(),
                              Text(
                                selectedByPassenger.values
                                    .map((seat) => seat.designator)
                                    .join(', '),
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton(
                              onPressed: selectedCount == widget.travelers
                                  ? continueNext
                                  : null,
                              child: const Text(
                                'CONTINUE',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _SeatMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}
