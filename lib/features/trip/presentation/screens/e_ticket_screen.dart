import 'package:flutter/material.dart';
import 'package:egypt_guide/features/trip/presentation/screens/boarding_pass_screen.dart';

class ETicketScreen extends StatelessWidget {
  final String from;
  final String to;
  final int travelers;
  final String travelClass;
  final DateTime departureDate;
  final Map<String, dynamic> flight;
  final List<String> selectedSeats;
  final List<Map<String, dynamic>> passengers;
  final int totalPrice;

  const ETicketScreen({
    super.key,
    required this.from,
    required this.to,
    required this.travelers,
    required this.travelClass,
    required this.departureDate,
    required this.flight,
    required this.selectedSeats,
    required this.passengers,
    required this.totalPrice,
  });

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatPrice(int value) {
    return 'EGP $value';
  }

  String passengerName(int index) {
    final passenger = passengers[index];

    final firstName =
        passenger['firstName']?.toString() ?? '';

    final lastName =
        passenger['lastName']?.toString() ?? '';

    return '$firstName $lastName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final airline =
        flight['airline']?.toString() ?? 'Airline';

    final departure =
        flight['departure']?.toString() ?? '--';

    final arrival =
        flight['arrival']?.toString() ?? '--';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF70E2F1),
              Color(0xFFA7DDF1),
              Color(0xFF83DEED),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      15,
                      18,
                      10,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius:
                              BorderRadius.circular(10),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white70,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'E-Ticket',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        10,
                        18,
                        25,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.all(18),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration:
                                                const BoxDecoration(
                                              color:
                                                  Color(0xFFEAF7FF),
                                              shape:
                                                  BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.flight,
                                              color:
                                                  Color(0xFF078DF5),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  airline,
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                                const Text(
                                                  'Electronic Ticket',
                                                  style:
                                                      TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const Icon(
                                            Icons
                                                .verified_outlined,
                                            color:
                                                Color(0xFF078DF5),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 25),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  from,
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                                Text(
                                                  departure,
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Color(
                                                      0xFFE63946,
                                                    ),
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const Padding(
                                            padding:
                                                EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.flight,
                                                  color: Color(
                                                    0xFF078DF5,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 65,
                                                  child: Divider(),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .end,
                                              children: [
                                                Text(
                                                  to,
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                  textAlign:
                                                      TextAlign.right,
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                                Text(
                                                  arrival,
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Color(
                                                      0xFFE63946,
                                                    ),
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Divider(height: 32),

                                      _TicketInfoRow(
                                        title: 'Date',
                                        value: formatDate(
                                          departureDate,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      _TicketInfoRow(
                                        title: 'Class',
                                        value: travelClass,
                                      ),

                                      const SizedBox(height: 12),

                                      _TicketInfoRow(
                                        title: 'Seats',
                                        value:
                                            selectedSeats.join(
                                          ', ',
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      _TicketInfoRow(
                                        title: 'Passengers',
                                        value: '$travelers',
                                      ),
                                    ],
                                  ),
                                ),

                                const _DottedDivider(),

                                Padding(
                                  padding:
                                      const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Passengers',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      ...List.generate(
                                        passengers.length,
                                        (index) {
                                          final seat =
                                              selectedSeats.length >
                                                      index
                                                  ? selectedSeats[
                                                      index]
                                                  : '-';

                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  alignment:
                                                      Alignment.center,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(
                                                      0xFFEAF7FF,
                                                    ),
                                                    shape:
                                                        BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    '${index + 1}',
                                                    style:
                                                        const TextStyle(
                                                      color: Color(
                                                        0xFF078DF5,
                                                      ),
                                                      fontWeight:
                                                          FontWeight
                                                              .bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    passengerName(
                                                      index,
                                                    ),
                                                    style:
                                                        const TextStyle(
                                                      fontWeight:
                                                          FontWeight
                                                              .w600,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Seat $seat',
                                                  style:
                                                      const TextStyle(
                                                    color: Color(
                                                      0xFF078DF5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const _DottedDivider(),

                                Padding(
                                  padding:
                                      const EdgeInsets.all(18),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'DEMO BOOKING REFERENCE',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      const Text(
                                        'EGY-DEMO-2026',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      const _DemoBarcode(),

                                      const SizedBox(height: 14),

                                      Text(
                                        formatPrice(totalPrice),
                                        style: const TextStyle(
                                          color:
                                              Color(0xFFE63946),
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.65,
                              ),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF078DF5),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'The boarding pass becomes available after airline check-in. The next screen is a demo until a real airline service is connected.',
                                    style: TextStyle(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BoardingPassScreen(
                                      from: from,
                                      to: to,
                                      travelClass:
                                          travelClass,
                                      departureDate:
                                          departureDate,
                                      flight: flight,
                                      selectedSeats:
                                          selectedSeats,
                                      passengers:
                                          passengers,
                                    ),
                                  ),
                                );
                              },
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF078DF5),
                                foregroundColor:
                                    Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    25,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'VIEW DEMO BOARDING PASS',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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

class _TicketInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _TicketInfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        25,
        (index) {
          return Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              color: index.isEven
                  ? Colors.grey.shade300
                  : Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}

class _DemoBarcode extends StatelessWidget {
  const _DemoBarcode();

  @override
  Widget build(BuildContext context) {
    final widths = [
      2.0,
      4.0,
      1.0,
      3.0,
      2.0,
      5.0,
      1.0,
      2.0,
      4.0,
      2.0,
      1.0,
      5.0,
      3.0,
      1.0,
      4.0,
      2.0,
      3.0,
      1.0,
      5.0,
      2.0,
    ];

    return SizedBox(
      height: 55,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: widths.map(
          (width) {
            return Container(
              width: width,
              height: 50,
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              color: Colors.black,
            );
          },
        ).toList(),
      ),
    );
  }
}