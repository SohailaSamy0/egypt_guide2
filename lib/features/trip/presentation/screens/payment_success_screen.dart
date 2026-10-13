import 'package:flutter/material.dart';
import 'package:egypt_guide/features/trip/presentation/screens/e_ticket_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String from;
  final String to;
  final int travelers;
  final String travelClass;
  final DateTime departureDate;
  final Map<String, dynamic> flight;
  final List<String> selectedSeats;
  final List<Map<String, dynamic>> passengers;
  final int totalPrice;

  const PaymentSuccessScreen({
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
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 115,
                      height: 115,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Color(0xFF078DF5),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Payment Successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Your booking has been confirmed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 35),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Text(
                            flight['airline']?.toString() ?? 'Airline',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  from,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Icon(
                                  Icons.flight,
                                  color: Color(0xFF078DF5),
                                ),
                              ),

                              Flexible(
                                child: Text(
                                  to,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 30),

                          Text(
                            'Seats: ${selectedSeats.join(', ')}',
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '$travelClass • $travelers '
                            'Traveler${travelers > 1 ? 's' : ''}',
                          ),

                          const SizedBox(height: 15),

                          Text(
                            'EGP $totalPrice',
                            style: const TextStyle(
                              color: Color(0xFFE63946),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ETicketScreen(
                                from: from,
                                to: to,
                                travelers: travelers,
                                travelClass: travelClass,
                                departureDate: departureDate,
                                flight: flight,
                                selectedSeats: selectedSeats,
                                passengers: passengers,
                                totalPrice: totalPrice,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF078DF5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'VIEW E-TICKET',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}