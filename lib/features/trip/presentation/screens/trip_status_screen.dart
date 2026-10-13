import 'package:flutter/material.dart';
import 'package:egypt_guide/features/preferences/presentation/screens/interests_screen.dart';
import 'package:egypt_guide/features/trip/presentation/screens/flight_search_screen.dart';

class TripStatusScreen extends StatelessWidget {
  const TripStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flight_takeoff,
                size: 100,
              ),
              const SizedBox(height: 30),

              const Text(
                'Plan Your Egypt Journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Tell us where you are in your journey so we can prepare the right experience for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 50),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FlightSearchScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.flight),
                label: const Text(
                  'I am planning my trip to Egypt',
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    55,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InterestsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.location_on_outlined,
                ),
                label: const Text(
                  "I'm already in Egypt",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}