import 'package:flutter/material.dart';
import 'package:egypt_guide/features/trip/presentation/screens/flight_details_screen.dart';

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
  State<SelectFlightScreen> createState() =>
      _SelectFlightScreenState();
}

class _SelectFlightScreenState extends State<SelectFlightScreen> {
  int? selectedFlight;

  final List<Map<String, dynamic>> flights = [
    {
      'airline': 'EgyptAir',
      'departure': '08:30 AM',
      'arrival': '09:30 AM',
      'duration': '1 hr',
      'price': 'EGP 3,250',
      'direct': true,
    },
    {
      'airline': 'Air Cairo',
      'departure': '10:15 AM',
      'arrival': '11:30 AM',
      'duration': '1 hr 15 min',
      'price': 'EGP 2,850',
      'direct': true,
    },
    {
      'airline': 'Nile Air',
      'departure': '01:20 PM',
      'arrival': '02:35 PM',
      'duration': '1 hr 15 min',
      'price': 'EGP 3,050',
      'direct': true,
    },
    {
      'airline': 'FlyEgypt',
      'departure': '04:10 PM',
      'arrival': '05:35 PM',
      'duration': '1 hr 25 min',
      'price': 'EGP 2,600',
      'direct': false,
    },
  ];

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      15,
                      16,
                      5,
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
                            width: 39,
                            height: 39,
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
                        const SizedBox(width: 12),
                        const Text(
                          'Select Your Flight',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Route
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AirportCircle(
                            value: widget.from,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.flight,
                                color: Color(0xFF087FF5),
                                size: 30,
                              ),
                              Container(
                                height: 1,
                                margin:
                                    const EdgeInsets.only(top: 4),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _AirportCircle(
                            value: widget.to,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.calendar_month,
                            text: formatDate(
                              widget.departureDate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.person,
                            text:
                                '${widget.travelers} passenger${widget.travelers > 1 ? 's' : ''}',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF65DDEA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.travelClass,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        4,
                        18,
                        20,
                      ),
                      itemCount: flights.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final flight = flights[index];

                        return _FlightCard(
                          airline:
                              flight['airline'] as String,
                          departure:
                              flight['departure'] as String,
                          arrival:
                              flight['arrival'] as String,
                          duration:
                              flight['duration'] as String,
                          price: flight['price'] as String,
                          direct: flight['direct'] as bool,
                          selected:
                              selectedFlight == index,
                          onTap: () {
                            setState(() {
                              selectedFlight = index;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      5,
                      18,
                      18,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: selectedFlight == null
    ? null
    : () {
        final flight = flights[selectedFlight!];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FlightDetailsScreen(
              from: widget.from,
              to: widget.to,
              departureDate: widget.departureDate,
              travelers: widget.travelers,
              travelClass: widget.travelClass,
              flight: flight,
            ),
          ),
        );
      },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF078DF5),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Colors.white38,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(24),
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

class _AirportCircle extends StatelessWidget {
  final String value;

  const _AirportCircle({
    required this.value,
  });

  String shortName() {
    final text = value.trim();

    if (text.length <= 3) {
      return text.toUpperCase();
    }

    return text
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(3)
        .map((word) => word[0])
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE5F7FF),
        shape: BoxShape.circle,
      ),
      child: Text(
        shortName(),
        style: const TextStyle(
          color: Color(0xFF087FF5),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.75,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF087FF5),
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF087FF5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final String airline;
  final String departure;
  final String arrival;
  final String duration;
  final String price;
  final bool direct;
  final bool selected;
  final VoidCallback onTap;

  const _FlightCard({
    required this.airline,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.price,
    required this.direct,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? const Color(0xFF078DF5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  departure,
                  style: const TextStyle(
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Icon(
                  Icons.flight,
                  color: Color(0xFF078DF5),
                  size: 21,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  arrival,
                  style: const TextStyle(
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              '$duration • ${direct ? 'Direct' : '1 stop'}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),

            const Divider(height: 22),

            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF7FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.airplanemode_active,
                    color: Color(0xFF078DF5),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    airline,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            if (selected) ...[
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF078DF5),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Selected',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF078DF5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}