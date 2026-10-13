import 'package:flutter/material.dart' hide Text;

import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:egypt_guide/core/widgets/aviation_background.dart';
import 'package:egypt_guide/features/flight/data/models/flight_booking.dart';
import 'package:egypt_guide/features/flight/data/models/flight_offer.dart';
import 'package:egypt_guide/features/flight/data/models/flight_seat.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final FlightBooking booking;
  final FlightOffer offer;
  final List<SelectedFlightSeat> selectedSeats;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.offer,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: AviationBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 82,
                    color: Color(0xFF00A76F),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Confirmed',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.liveMode
                        ? 'Your airline booking is confirmed.'
                        : 'Test booking confirmed. No real ticket was issued.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        _Row(
                          title: 'Booking Reference',
                          value: booking.bookingReference.isEmpty
                              ? '-'
                              : booking.bookingReference,
                          strong: true,
                        ),
                        const Divider(height: 26),
                        _Row(
                          title: 'Airline',
                          value: booking.airlineName.isEmpty
                              ? offer.airlineName
                              : booking.airlineName,
                        ),
                        const SizedBox(height: 12),
                        _Row(
                          title: 'Route',
                          value: '${offer.origin} → ${offer.destination}',
                        ),
                        const SizedBox(height: 12),
                        _Row(
                          title: 'Seats',
                          value: selectedSeats.isEmpty
                              ? 'Assigned by airline'
                              : selectedSeats
                                  .map((seat) => seat.designator)
                                  .join(', '),
                        ),
                        const SizedBox(height: 12),
                        _Row(
                          title: 'Total',
                          value:
                              '${booking.totalAmount} ${booking.totalCurrency}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text(
                        'DONE',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
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

class _Row extends StatelessWidget {
  final String title;
  final String value;
  final bool strong;

  const _Row({
    required this.title,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
