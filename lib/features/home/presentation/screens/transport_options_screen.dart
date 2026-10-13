import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/features/home/presentation/screens/fair_price_checker_screen.dart';

class TransportOptionsScreen extends StatelessWidget {
  final String destinationName;
  final double distanceKm;
  final double drivingMinutes;

  const TransportOptionsScreen({
    super.key,
    required this.destinationName,
    required this.distanceKm,
    required this.drivingMinutes,
  });

  int get walkingMinutes {
    const walkingSpeedKmPerHour = 4.5;

    final hours =
        distanceKm / walkingSpeedKmPerHour;

    return (hours * 60).round();
  }

  int get taxiMinPrice {
    const baseFare = 15.0;
    const minimumPerKm = 8.0;

    return (
      baseFare +
      distanceKm * minimumPerKm
    ).round();
  }

  int get taxiMaxPrice {
    const baseFare = 20.0;
    const maximumPerKm = 12.0;

    return (
      baseFare +
      distanceKm * maximumPerKm
    ).round();
  }

  int get publicTransportMinPrice {
    if (distanceKm <= 5) {
      return 10;
    }

    if (distanceKm <= 15) {
      return 15;
    }

    return 20;
  }

  int get publicTransportMaxPrice {
    if (distanceKm <= 5) {
      return 20;
    }

    if (distanceKm <= 15) {
      return 30;
    }

    return 40;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transportation',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 500,
          ),
          child: ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              Text(
                'Trip to',
                style: TextStyle(
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                destinationName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.route,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km',
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _TransportCard(
                icon:
                    Icons.directions_walk,
                title: 'Walking',
                subtitle:
                    'Best for short distances',
                time:
                    '$walkingMinutes min',
                price: 'Free',
                badge: distanceKm <= 2
                    ? 'Recommended'
                    : null,
              ),

              const SizedBox(height: 14),

              _TransportCard(
                icon:
                    Icons.directions_car,
                title: 'Car',
                subtitle:
                    'Estimated driving time',
                time:
                    '${drivingMinutes.round()} min',
                price:
                    'Depends on vehicle',
              ),

              const SizedBox(height: 14),

              _TransportCard(
                icon:
                    Icons.local_taxi_outlined,
                title: 'Taxi / Ride',
                subtitle:
                    'Prototype price estimate',
                time:
                    '${drivingMinutes.round()} min',
                price:
                    'EGP $taxiMinPrice - $taxiMaxPrice',
                badge: 'Demo Estimate',
              ),

              const SizedBox(height: 14),

              _TransportCard(
                icon:
                    Icons.directions_bus_outlined,
                title:
                    'Public Transport',
                subtitle:
                    'Prototype estimate',
                time:
                    '${(drivingMinutes * 1.7).round()} min',
                price:
                    'EGP $publicTransportMinPrice - $publicTransportMaxPrice',
                badge: 'Demo Estimate',
              ),

              const SizedBox(height: 25),

              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color:
                          colorScheme.primary,
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        'Transport prices shown here are prototype estimates and are not live prices yet.',
                        style: TextStyle(
                          height: 1.4,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 48,
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FairPriceCheckerScreen(
                          destinationName:
                              destinationName,
                          distanceKm:
                              distanceKm,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.price_check,
                  ),
                  label: const Text(
                    'CHECK FAIR PRICE',
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

class _TransportCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final String price;
  final String? badge;

  const _TransportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.price,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    if (badge != null) ...[
                      const SizedBox(
                        width: 8,
                      ),

                      Flexible(
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration:
                              BoxDecoration(
                            color: colorScheme
                                .primaryContainer,
                            borderRadius:
                                BorderRadius
                                    .circular(10),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 9,
                              color:
                                  colorScheme
                                      .primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 15,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      time,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Icon(
                      Icons.payments_outlined,
                      size: 15,
                    ),

                    const SizedBox(width: 4),

                    Flexible(
                      child: Text(
                        price,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}