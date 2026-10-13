import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:egypt_guide/features/home/data/models/nearby_place.dart';
import 'package:egypt_guide/features/safety/data/services/nearby_safety_service.dart';

class SafetyCenterScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const SafetyCenterScreen({
    super.key,
    this.latitude,
    this.longitude,
  });

  @override
  State<SafetyCenterScreen> createState() =>
      _SafetyCenterScreenState();
}

class _SafetyCenterScreenState
    extends State<SafetyCenterScreen> {
  final NearbySafetyService
      nearbySafetyService =
      NearbySafetyService();

  bool isLoadingNearbyHelp = false;

  Future<void> callNumber(
    BuildContext context,
    String number,
  ) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: number,
    );

    try {
      final bool opened =
          await launchUrl(uri);

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the phone dialer.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not make the call.',
          ),
        ),
      );
    }
  }

  Future<void> loadNearbyHelp(
    String type,
  ) async {
    if (widget.latitude == null ||
        widget.longitude == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Your current location is not available. Enable location first.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoadingNearbyHelp = true;
    });

    try {
      final places =
          await nearbySafetyService
              .getNearbyHelp(
        latitude: widget.latitude!,
        longitude: widget.longitude!,
        type: type,
      );

      if (!mounted) return;

      if (places.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'No nearby ${type.toLowerCase()} locations were found.',
            ),
          ),
        );

        return;
      }

      showNearbyResults(
        type,
        places,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not load nearby help. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingNearbyHelp = false;
        });
      }
    }
  }

  void showNearbyResults(
    String type,
    List<NearbyPlace> places,
  ) {
    final origin = LatLng(
      widget.latitude!,
      widget.longitude!,
    );

    final distance = Distance();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (
        bottomSheetContext,
      ) {
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.sizeOf(context)
                        .height *
                    0.72,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    0,
                    20,
                    14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        nearbyIcon(type),
                        color: Theme.of(
                          context,
                        )
                            .colorScheme
                            .primary,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          'Nearest ${nearbyTitle(type)}',
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                ),

                Expanded(
                  child:
                      ListView.separated(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    itemCount:
                        places.length,
                    separatorBuilder:
                        (
                      context,
                      index,
                    ) =>
                            const Divider(),
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final place =
                          places[index];

                      final km =
                          distance.as(
                        LengthUnit
                            .Kilometer,
                        origin,
                        LatLng(
                          place.latitude,
                          place.longitude,
                        ),
                      );

                      return ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        leading:
                            CircleAvatar(
                          child: Icon(
                            nearbyIcon(
                              type,
                            ),
                          ),
                        ),
                        title: Text(
                          place.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                        subtitle: Text(
                          '${km.toStringAsFixed(1)} km away',
                        ),
                        trailing:
                            const Icon(
                          Icons
                              .chevron_right,
                        ),
                        onTap: () {
                          Navigator.pop(
                            bottomSheetContext,
                          );

                          Navigator.pop(
                            context,
                            place,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData nearbyIcon(
    String type,
  ) {
    switch (type) {
      case 'Hospital':
        return Icons
            .local_hospital_outlined;

      case 'Pharmacy':
        return Icons
            .local_pharmacy_outlined;

      case 'Police':
        return Icons
            .local_police_outlined;

      default:
        return Icons.place_outlined;
    }
  }

  String nearbyTitle(
    String type,
  ) {
    switch (type) {
      case 'Hospital':
        return 'Hospitals';

      case 'Pharmacy':
        return 'Pharmacies';

      case 'Police':
        return 'Police Stations';

      default:
        return 'Help';
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    final contacts = [
      const EmergencyContact(
        title: 'Police',
        number: '122',
        icon:
            Icons.local_police_outlined,
      ),
      const EmergencyContact(
        title: 'Tourist Police',
        number: '126',
        icon: Icons.shield_outlined,
      ),
      const EmergencyContact(
        title: 'Ambulance',
        number: '123',
        icon: Icons
            .medical_services_outlined,
      ),
      const EmergencyContact(
        title: 'Fire Service',
        number: '180',
        icon: Icons
            .local_fire_department_outlined,
      ),
      const EmergencyContact(
        title:
            'Tourism Information',
        number: '19654',
        icon: Icons.support_agent,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safety Center',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 550,
          ),
          child: ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              Container(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(
                        0xFF078DF5,
                      ),
                      Color(
                        0xFF56C7E8,
                      ),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons
                          .health_and_safety_outlined,
                      size: 60,
                      color:
                          Colors.white,
                    ),

                    SizedBox(
                      height: 12,
                    ),

                    Text(
                      'Travel Safely in Egypt',
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 25,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Emergency contacts, nearby help and useful travel guidance in one place.',
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        color: Colors
                            .white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              const Text(
                'Nearby Help',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                'Find essential services close to your current location.',
                style: TextStyle(
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        NearbyHelpCard(
                      icon: Icons
                          .local_hospital_outlined,
                      title:
                          'Hospital',
                      onTap: () {
                        loadNearbyHelp(
                          'Hospital',
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        NearbyHelpCard(
                      icon: Icons
                          .local_pharmacy_outlined,
                      title:
                          'Pharmacy',
                      onTap: () {
                        loadNearbyHelp(
                          'Pharmacy',
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        NearbyHelpCard(
                      icon: Icons
                          .local_police_outlined,
                      title:
                          'Police',
                      onTap: () {
                        loadNearbyHelp(
                          'Police',
                        );
                      },
                    ),
                  ),
                ],
              ),

              if (isLoadingNearbyHelp) ...[
                const SizedBox(
                  height: 12,
                ),
                const LinearProgressIndicator(),
              ],

              const SizedBox(
                height: 30,
              ),

              const Text(
                'Emergency Numbers',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                'Tap a number to open your phone dialer.',
                style: TextStyle(
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    contacts.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                      1.15,
                ),
                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final contact =
                      contacts[index];

                  return EmergencyCard(
                    contact:
                        contact,
                    onCall: () {
                      callNumber(
                        context,
                        contact.number,
                      );
                    },
                  );
                },
              ),

              const SizedBox(
                height: 30,
              ),

              const Text(
                'Tourist Safety Tips',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              const SafetyTip(
                icon:
                    Icons.payments_outlined,
                title:
                    'Ask for the price first',
                description:
                    'Before using a taxi, tour service or tourist activity, confirm the price and what is included.',
              ),

              const SizedBox(
                height: 10,
              ),

              const SafetyTip(
                icon: Icons
                    .receipt_long_outlined,
                title:
                    'Keep receipts',
                description:
                    'Keep receipts for tickets, purchases and paid services whenever available.',
              ),

              const SizedBox(
                height: 10,
              ),

              const SafetyTip(
                icon:
                    Icons.wallet_outlined,
                title:
                    'Protect your valuables',
                description:
                    'Keep your passport, wallet and important belongings secure, especially in crowded areas.',
              ),

              const SizedBox(
                height: 10,
              ),

              const SafetyTip(
                icon:
                    Icons.map_outlined,
                title:
                    'Check your route',
                description:
                    'Review your destination and approximate route before starting a trip.',
              ),

              const SizedBox(
                height: 10,
              ),

              const SafetyTip(
                icon:
                    Icons.price_check,
                title:
                    'Compare prices',
                description:
                    'Use the Fair Price Checker when you are unsure whether a quoted price is reasonable.',
              ),

              const SizedBox(
                height: 30,
              ),

              const Text(
                'Common Situations',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              SituationCard(
                icon: Icons
                    .local_taxi_outlined,
                title:
                    'Taxi price seems too high',
                description:
                    'Confirm the destination and quoted price. Compare it with the app estimate before accepting when possible.',
                color: colorScheme
                    .primaryContainer,
              ),

              const SizedBox(
                height: 10,
              ),

              SituationCard(
                icon: Icons
                    .shopping_bag_outlined,
                title:
                    'A seller is pressuring you',
                description:
                    'You are free to decline an offer. Compare prices and avoid rushing into a purchase.',
                color: colorScheme
                    .secondaryContainer,
              ),

              const SizedBox(
                height: 10,
              ),

              SituationCard(
                icon:
                    Icons.badge_outlined,
                title:
                    'Lost passport or important documents',
                description:
                    'Contact the relevant authorities and your embassy or consulate as soon as possible.',
                color: colorScheme
                    .tertiaryContainer,
              ),

              const SizedBox(
                height: 10,
              ),

              SituationCard(
                icon: Icons
                    .report_problem_outlined,
                title:
                    'Serious tourist issue',
                description:
                    'For serious tourism-related matters, contact Tourist Police on 126.',
                color: colorScheme
                    .errorContainer,
              ),

              const SizedBox(
                height: 30,
              ),

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color: colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme
                          .primary,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    const Expanded(
                      child: Text(
                        'In an emergency, contact the appropriate official emergency service. App guidance is not a replacement for emergency services.',
                        style:
                            TextStyle(
                          fontSize:
                              12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyContact {
  final String title;
  final String number;
  final IconData icon;

  const EmergencyContact({
    required this.title,
    required this.number,
    required this.icon,
  });
}

class NearbyHelpCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const NearbyHelpCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Material(
      color:
          colorScheme.surface,
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        child: Container(
          padding:
              const EdgeInsets
                  .symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: colorScheme
                  .outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: colorScheme
                    .primary,
                size: 30,
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyCard
    extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onCall;

  const EmergencyCard({
    super.key,
    required this.contact,
    required this.onCall,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Material(
      color:
          colorScheme.surface,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      child: InkWell(
        onTap: onCall,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child: Container(
          padding:
              const EdgeInsets.all(
            14,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: colorScheme
                  .outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                    BoxDecoration(
                  color: colorScheme
                      .primaryContainer,
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  contact.icon,
                  color: colorScheme
                      .primary,
                ),
              ),

              const SizedBox(
                height: 9,
              ),

              Text(
                contact.title,
                textAlign:
                    TextAlign.center,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                contact.number,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color: colorScheme
                      .primary,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              const Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Icon(
                    Icons.call_outlined,
                    size: 13,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    'Call',
                    style:
                        TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SafetyTip
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const SafetyTip({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: colorScheme
              .outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Icon(
            icon,
            color:
                colorScheme.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  description,
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 12,
                    color:
                        colorScheme
                            .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SituationCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const SituationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Icon(icon),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  description,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}