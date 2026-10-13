import 'package:flutter/material.dart';

class BoardingPassScreen extends StatelessWidget {
  final String from;
  final String to;
  final String travelClass;
  final DateTime departureDate;
  final Map<String, dynamic> flight;
  final List<String> selectedSeats;
  final List<Map<String, dynamic>> passengers;

  const BoardingPassScreen({
    super.key,
    required this.from,
    required this.to,
    required this.travelClass,
    required this.departureDate,
    required this.flight,
    required this.selectedSeats,
    required this.passengers,
  });

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get passengerName {
    if (passengers.isEmpty) {
      return 'Passenger';
    }

    final firstName =
        passengers.first['firstName']?.toString() ?? '';

    final lastName =
        passengers.first['lastName']?.toString() ?? '';

    return '$firstName $lastName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final airline =
        flight['airline']?.toString() ?? 'Airline';

    final departure =
        flight['departure']?.toString() ?? '--';

    final seat = selectedSeats.isNotEmpty
        ? selectedSeats.first
        : '-';

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
                          'Boarding Pass',
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
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(22),
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
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.all(
                                    18,
                                  ),
                                  decoration:
                                      const BoxDecoration(
                                    color:
                                        Color(0xFF078DF5),
                                    borderRadius:
                                        BorderRadius.only(
                                      topLeft:
                                          Radius.circular(22),
                                      topRight:
                                          Radius.circular(22),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.flight,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          airline,
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,
                                            fontSize: 17,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'DEMO',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding:
                                      const EdgeInsets.all(
                                    20,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              from,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              style:
                                                  const TextStyle(
                                                fontSize: 22,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),

                                          const Padding(
                                            padding:
                                                EdgeInsets
                                                    .symmetric(
                                              horizontal: 10,
                                            ),
                                            child: Icon(
                                              Icons.flight,
                                              color: Color(
                                                0xFF078DF5,
                                              ),
                                            ),
                                          ),

                                          Expanded(
                                            child: Text(
                                              to,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              textAlign:
                                                  TextAlign.right,
                                              style:
                                                  const TextStyle(
                                                fontSize: 22,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Divider(
                                        height: 35,
                                      ),

                                      _BoardingRow(
                                        leftTitle:
                                            'Passenger',
                                        leftValue:
                                            passengerName,
                                        rightTitle:
                                            'Seat',
                                        rightValue: seat,
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),

                                      _BoardingRow(
                                        leftTitle: 'Date',
                                        leftValue:
                                            formatDate(
                                          departureDate,
                                        ),
                                        rightTitle:
                                            'Class',
                                        rightValue:
                                            travelClass,
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),

                                      _BoardingRow(
                                        leftTitle:
                                            'Departure',
                                        leftValue:
                                            departure,
                                        rightTitle:
                                            'Gate',
                                        rightValue:
                                            'Demo',
                                      ),
                                    ],
                                  ),
                                ),

                                const _CutLine(),

                                const Padding(
                                  padding: EdgeInsets.all(
                                    22,
                                  ),
                                  child: Column(
                                    children: [
                                      _DemoQrCode(),
                                      SizedBox(height: 12),
                                      Text(
                                        'DEMO BOARDING PASS',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            padding:
                                const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withValues(
                                alpha: 0.7,
                              ),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_outlined,
                                  color: Color(0xFF078DF5),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'This is a UI demonstration, not a valid boarding pass. A real boarding pass must come from the airline after check-in.',
                                    style: TextStyle(
                                      fontSize: 11,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardingRow extends StatelessWidget {
  final String leftTitle;
  final String leftValue;
  final String rightTitle;
  final String rightValue;

  const _BoardingRow({
    required this.leftTitle,
    required this.leftValue,
    required this.rightTitle,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                leftTitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                leftValue,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                rightTitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rightValue,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CutLine extends StatelessWidget {
  const _CutLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        28,
        (index) {
          return Expanded(
            child: Container(
              height: 1,
              margin:
                  const EdgeInsets.symmetric(
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

class _DemoQrCode extends StatelessWidget {
  const _DemoQrCode();

  @override
  Widget build(BuildContext context) {
    const pattern = [
      1, 1, 1, 0, 1, 0, 1, 1,
      1, 0, 1, 1, 0, 1, 0, 1,
      1, 1, 0, 1, 1, 0, 1, 1,
      0, 1, 1, 0, 1, 1, 0, 1,
      1, 0, 1, 1, 0, 1, 1, 0,
      0, 1, 0, 1, 1, 0, 1, 1,
      1, 1, 0, 0, 1, 1, 0, 1,
      1, 0, 1, 1, 0, 1, 1, 1,
    ];

    return SizedBox(
      width: 130,
      height: 130,
      child: GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: pattern.length,
        itemBuilder: (
          context,
          index,
        ) {
          return Container(
            color: pattern[index] == 1
                ? Colors.black
                : Colors.white,
          );
        },
      ),
    );
  }
}