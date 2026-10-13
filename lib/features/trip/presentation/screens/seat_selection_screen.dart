import 'package:flutter/material.dart';
import 'package:egypt_guide/features/trip/presentation/screens/passenger_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String from;
final String to;
final int travelers;
final String travelClass;
final DateTime departureDate;
final Map<String, dynamic> flight;

 const SeatSelectionScreen({
  super.key,
  required this.from,
  required this.to,
  required this.travelers,
  required this.travelClass,
  required this.departureDate,
  required this.flight,
});
  @override
  State<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // الكراسي التي اختارها المستخدم
  final Set<String> selectedSeats = {};

  // كراسي محجوزة مؤقتًا للتجربة
  // لاحقًا هتيجي من الـ API الحقيقي
  final Set<String> reservedSeats = {
    '2A',
    '2F',
    '4C',
    '5D',
    '7A',
    '7B',
    '9E',
    '10F',
    '13A',
    '14C',
    '16D',
    '18F',
  };

  bool get isBusiness {
    final travelClass = widget.travelClass.toLowerCase();

    return travelClass.contains('business') ||
        travelClass.contains('first');
  }

  int get totalRows {
    if (isBusiness) {
      return 8;
    }

    return 18;
  }

  void selectSeat(String seat) {
    // لو الكرسي محجوز
    if (reservedSeats.contains(seat)) {
      return;
    }

    setState(() {
      // لو الكرسي مختار بالفعل، شيل الاختيار
      if (selectedSeats.contains(seat)) {
        selectedSeats.remove(seat);
        return;
      }

      // منع اختيار عدد كراسي أكبر من عدد المسافرين
      if (selectedSeats.length >= widget.travelers) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can select only ${widget.travelers} '
              'seat${widget.travelers > 1 ? 's' : ''}.',
            ),
          ),
        );

        return;
      }

      selectedSeats.add(seat);
    });
  }

  // صف Economy
  Widget buildEconomyRow(int row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSeat('${row}A'),
        const SizedBox(width: 7),

        _buildSeat('${row}B'),
        const SizedBox(width: 7),

        _buildSeat('${row}C'),

        const SizedBox(width: 15),

        SizedBox(
          width: 24,
          child: Center(
            child: Text(
              '$row',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
        ),

        const SizedBox(width: 15),

        _buildSeat('${row}D'),
        const SizedBox(width: 7),

        _buildSeat('${row}E'),
        const SizedBox(width: 7),

        _buildSeat('${row}F'),
      ],
    );
  }

  // صف Business
  Widget buildBusinessRow(int row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSeat(
          '${row}A',
          business: true,
        ),

        const SizedBox(width: 12),

        _buildSeat(
          '${row}C',
          business: true,
        ),

        const SizedBox(width: 24),

        SizedBox(
          width: 24,
          child: Center(
            child: Text(
              '$row',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        _buildSeat(
          '${row}D',
          business: true,
        ),

        const SizedBox(width: 12),

        _buildSeat(
          '${row}F',
          business: true,
        ),
      ],
    );
  }

  Widget _buildSeat(
    String seat, {
    bool business = false,
  }) {
    final bool isReserved = reservedSeats.contains(seat);
    final bool isSelected = selectedSeats.contains(seat);

    return _SeatButton(
      seat: seat,
      reserved: isReserved,
      selected: isSelected,
      business: business,
      onTap: () {
        selectSeat(seat);
      },
    );
  }

  void continueToPayment() {
  if (selectedSeats.length != widget.travelers) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please select ${widget.travelers} '
          'seat${widget.travelers > 1 ? 's' : ''}.',
        ),
      ),
    );

    return;
  }

  final seats = selectedSeats.toList()
    ..sort();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PassengerDetailsScreen(
        from: widget.from,
        to: widget.to,
        travelers: widget.travelers,
        travelClass: widget.travelClass,
        departureDate:
            widget.departureDate,
        flight: widget.flight,
        selectedSeats: seats,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
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
                  // Header
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
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
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

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Seat',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                widget.travelClass,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flight Info
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flight,
                            color: Color(0xFF078DF5),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              '${widget.from}  →  ${widget.to}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          Text(
                            widget.flight['airline'] as String,
                            style: const TextStyle(
                              color: Color(0xFF078DF5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Seat Status
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        _SeatLegend(
                          color: Colors.white,
                          text: 'Available',
                          borderColor: Color(0xFFBDBDBD),
                        ),
                        _SeatLegend(
                          color: Color(0xFF078DF5),
                          text: 'Selected',
                        ),
                        _SeatLegend(
                          color: Color(0xFFDADADA),
                          text: 'Reserved',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Plane / Seats
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        10,
                        18,
                        10,
                        15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(80),
                          topRight: Radius.circular(80),
                        ),
                        border: Border.all(
                          color: Colors.white,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.flight,
                            size: 30,
                            color: Color(0xFF078DF5),
                          ),

                          const SizedBox(height: 14),

                          if (isBusiness)
                            const _BusinessLabels()
                          else
                            const _EconomyLabels(),

                          const SizedBox(height: 8),

                          Expanded(
                            child: ListView.separated(
                              itemCount: totalRows,
                              separatorBuilder: (
                                context,
                                index,
                              ) {
                                return const SizedBox(
                                  height: 10,
                                );
                              },
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                final int row = index + 1;

                                if (isBusiness) {
                                  return buildBusinessRow(row);
                                }

                                return buildEconomyRow(row);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      12,
                      18,
                      18,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedSeats.isEmpty
                                    ? 'Choose ${widget.travelers} '
                                        'seat${widget.travelers > 1 ? 's' : ''}'
                                    : 'Seats: ${selectedSeats.join(', ')}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            Text(
                              '${selectedSeats.length}/${widget.travelers}',
                              style: const TextStyle(
                                color: Color(0xFF078DF5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 47,
                          child: ElevatedButton(
                            onPressed: continueToPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF078DF5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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

// ============================================================
// Seat Button
// ============================================================

class _SeatButton extends StatelessWidget {
  final String seat;
  final bool reserved;
  final bool selected;
  final bool business;
  final VoidCallback onTap;

  const _SeatButton({
    required this.seat,
    required this.reserved,
    required this.selected,
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (reserved) {
      backgroundColor = const Color(0xFFDADADA);
      borderColor = const Color(0xFFDADADA);
      textColor = Colors.grey;
    } else if (selected) {
      backgroundColor = const Color(0xFF078DF5);
      borderColor = const Color(0xFF078DF5);
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white;
      borderColor = const Color(0xFFAFC5CE);
      textColor = Colors.black87;
    }

    return InkWell(
      onTap: reserved ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        width: business ? 47 : 38,
        height: business ? 45 : 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          seat.replaceAll(
            RegExp(r'[0-9]'),
            '',
          ),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Legend
// ============================================================

class _SeatLegend extends StatelessWidget {
  final Color color;
  final String text;
  final Color? borderColor;

  const _SeatLegend({
    required this.color,
    required this.text,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: borderColor ??
                  Colors.transparent,
            ),
          ),
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Economy Seat Letters
// ============================================================

class _EconomyLabels extends StatelessWidget {
  const _EconomyLabels();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Text('A'),
        SizedBox(width: 30),
        Text('B'),
        SizedBox(width: 30),
        Text('C'),

        SizedBox(width: 70),

        Text('D'),
        SizedBox(width: 30),
        Text('E'),
        SizedBox(width: 30),
        Text('F'),
      ],
    );
  }
}

// ============================================================
// Business Seat Letters
// ============================================================

class _BusinessLabels extends StatelessWidget {
  const _BusinessLabels();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Text('A'),
        SizedBox(width: 48),
        Text('C'),

        SizedBox(width: 98),

        Text('D'),
        SizedBox(width: 48),
        Text('F'),
      ],
    );
  }
}