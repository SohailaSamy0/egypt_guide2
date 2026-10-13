import 'package:flutter/material.dart' hide Text;

import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:egypt_guide/core/widgets/aviation_background.dart';
import 'package:egypt_guide/features/flight/data/models/flight_offer.dart';
import 'package:egypt_guide/features/flight/data/services/flight_service.dart';
import 'package:egypt_guide/features/flight/presentation/screens/seat_selection_screen.dart';

class SelectFlightScreen extends StatefulWidget {
  final String from;
  final String to;
  final DateTime departureDate;
  final int travelers;
  final String travelClass;

  const SelectFlightScreen({
    super.key,
    required this.from,
    required this.to,
    required this.departureDate,
    required this.travelers,
    required this.travelClass,
  });

  @override
  State<SelectFlightScreen> createState() => _SelectFlightScreenState();
}

class _SelectFlightScreenState extends State<SelectFlightScreen> {
  final FlightService flightService = FlightService();

  bool loading = true;
  String? errorMessage;
  List<FlightOffer> offers = const [];

  @override
  void initState() {
    super.initState();
    loadFlights();
  }

  Future<void> loadFlights() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await flightService.searchFlights(
        origin: widget.from,
        destination: widget.to,
        departureDate: widget.departureDate,
        travelers: widget.travelers,
        travelClass: widget.travelClass,
      );

      if (!mounted) return;
      setState(() => offers = result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('Route not found',
                'Live flight provider is not connected to the backend yet.');
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _time(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _date(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: AviationBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                                'Available Flights',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${widget.from} → ${widget.to} • ${_date(widget.departureDate)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: loading ? null : loadFlights,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage != null
                            ? _ErrorState(
                                message: errorMessage!,
                                onRetry: loadFlights,
                              )
                            : offers.isEmpty
                                ? _EmptyState(onRetry: loadFlights)
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                    itemCount: offers.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final offer = offers[index];
                                      return Material(
                                        color: colors.surface.withValues(alpha: 0.94),
                                        borderRadius: BorderRadius.circular(20),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => SeatSelectionScreen(
                                                  offer: offer,
                                                  travelers: widget.travelers,
                                                  travelClass: widget.travelClass,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          colors.primaryContainer,
                                                      child: const Icon(
                                                        Icons.flight_rounded,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            offer.airlineName,
                                                            style: const TextStyle(
                                                              fontSize: 17,
                                                              fontWeight: FontWeight.w800,
                                                            ),
                                                          ),
                                                          if (offer.flightNumber.isNotEmpty)
                                                            Text(
                                                              '${offer.airlineIataCode} ${offer.flightNumber}',
                                                              style: TextStyle(
                                                                color: colors.onSurfaceVariant,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      '${offer.totalAmount.toStringAsFixed(2)} ${offer.currency}',
                                                      style: TextStyle(
                                                        color: colors.primary,
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 18),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _TimeBlock(
                                                        time: _time(offer.departureAt),
                                                        airport: offer.origin,
                                                        align: CrossAxisAlignment.start,
                                                      ),
                                                    ),
                                                    Column(
                                                      children: [
                                                        const Icon(Icons.flight_takeoff_rounded),
                                                        const SizedBox(height: 3),
                                                        Text(
                                                          offer.stops == 0
                                                              ? 'Direct'
                                                              : '${offer.stops} stop',
                                                          style: const TextStyle(fontSize: 11),
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: _TimeBlock(
                                                        time: _time(offer.arrivalAt),
                                                        airport: offer.destination,
                                                        align: CrossAxisAlignment.end,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 14),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.schedule_rounded,
                                                      size: 17,
                                                      color: colors.onSurfaceVariant,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      offer.duration.isEmpty
                                                          ? 'Flight duration'
                                                          : offer.duration,
                                                      style: TextStyle(
                                                        color: colors.onSurfaceVariant,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      offer.liveMode ? 'LIVE' : 'TEST',
                                                      style: TextStyle(
                                                        color: offer.liveMode
                                                            ? const Color(0xFF00875A)
                                                            : colors.tertiary,
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(Icons.chevron_right_rounded),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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

class _TimeBlock extends StatelessWidget {
  final String time;
  final String airport;
  final CrossAxisAlignment align;

  const _TimeBlock({
    required this.time,
    required this.airport,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        Text(
          airport,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56),
            const SizedBox(height: 14),
            const Text(
              'Could not load live flights',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flight_outlined, size: 56),
          const SizedBox(height: 12),
          const Text(
            'No flights found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('TRY AGAIN')),
        ],
      ),
    );
  }
}
