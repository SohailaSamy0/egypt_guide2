import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:egypt_guide/core/localization/app_localizations.dart';

class FairPriceCheckerScreen extends StatefulWidget {
  final String? destinationName;
  final double? distanceKm;

  const FairPriceCheckerScreen({
    super.key,
    this.destinationName,
    this.distanceKm,
  });

  @override
  State<FairPriceCheckerScreen> createState() =>
      _FairPriceCheckerScreenState();
}

class _FairPriceCheckerScreenState
    extends State<FairPriceCheckerScreen> {
  final TextEditingController priceController =
      TextEditingController();

  String selectedService = 'Taxi';

  String? resultTitle;
  String? resultMessage;
  Color? resultColor;
  IconData? resultIcon;

  final List<String> services = [
    'Taxi',
    'Souvenir',
    'Tour Guide',
    'Camel Ride',
    'Restaurant Meal',
  ];

  int get taxiMinPrice {
    final distance = widget.distanceKm ?? 5;

    const baseFare = 15.0;
    const perKm = 8.0;

    return (baseFare + distance * perKm).round();
  }

  int get taxiMaxPrice {
    final distance = widget.distanceKm ?? 5;

    const baseFare = 20.0;
    const perKm = 12.0;

    return (baseFare + distance * perKm).round();
  }

  int get minPrice {
    switch (selectedService) {
      case 'Taxi':
        return taxiMinPrice;

      case 'Souvenir':
        return 50;

      case 'Tour Guide':
        return 300;

      case 'Camel Ride':
        return 150;

      case 'Restaurant Meal':
        return 120;

      default:
        return 0;
    }
  }

  int get maxPrice {
    switch (selectedService) {
      case 'Taxi':
        return taxiMaxPrice;

      case 'Souvenir':
        return 300;

      case 'Tour Guide':
        return 800;

      case 'Camel Ride':
        return 500;

      case 'Restaurant Meal':
        return 500;

      default:
        return 0;
    }
  }

  String get serviceDescription {
    switch (selectedService) {
      case 'Taxi':
        return widget.distanceKm != null
            ? 'Estimated for a ${widget.distanceKm!.toStringAsFixed(1)} km trip.'
            : 'General prototype estimate.';

      case 'Souvenir':
        return 'Prototype range for common tourist souvenirs.';

      case 'Tour Guide':
        return 'Prototype estimate for a basic guided experience.';

      case 'Camel Ride':
        return 'Prototype estimate for a short tourist ride.';

      case 'Restaurant Meal':
        return 'Prototype estimate for one person at a casual restaurant.';

      default:
        return '';
    }
  }

  IconData serviceIcon(String service) {
    switch (service) {
      case 'Taxi':
        return Icons.local_taxi_outlined;

      case 'Souvenir':
        return Icons.shopping_bag_outlined;

      case 'Tour Guide':
        return Icons.record_voice_over_outlined;

      case 'Camel Ride':
        return Icons.landscape_outlined;

      case 'Restaurant Meal':
        return Icons.restaurant_outlined;

      default:
        return Icons.price_check;
    }
  }

  void checkPrice() {
    final enteredPrice =
        double.tryParse(priceController.text.trim());

    if (enteredPrice == null || enteredPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid price.',
          ),
        ),
      );

      return;
    }

    final min = minPrice.toDouble();
    final max = maxPrice.toDouble();

    if (enteredPrice < min) {
      setState(() {
        resultTitle = 'Below Expected Range';
        resultMessage =
            'This price is below our current prototype range. Confirm exactly what is included before paying.';
        resultColor = Colors.blue;
        resultIcon = Icons.info_outline;
      });

      return;
    }

    if (enteredPrice <= max) {
      setState(() {
        resultTitle = 'Fair Price';
        resultMessage =
            'The quoted price is within the expected prototype range.';
        resultColor = Colors.green;
        resultIcon = Icons.check_circle_outline;
      });

      return;
    }

    if (enteredPrice <= max * 1.30) {
      setState(() {
        resultTitle = 'A Little High';
        resultMessage =
            'The price is slightly above the expected range. You may want to compare another option before paying.';
        resultColor = Colors.orange;
        resultIcon = Icons.warning_amber_outlined;
      });

      return;
    }

    setState(() {
      resultTitle = 'Price Looks Too High';
      resultMessage =
          'This quote is significantly above our expected prototype range. Consider comparing prices or asking for clarification.';
      resultColor = Colors.red;
      resultIcon = Icons.error_outline;
    });
  }

  void resetResult() {
    setState(() {
      resultTitle = null;
      resultMessage = null;
      resultColor = null;
      resultIcon = null;
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fair Price Checker',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Know Before You Pay',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Compare a quoted price with our current expected range.',
                style: TextStyle(
                  color:
                      colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              if (widget.destinationName != null) ...[
                const SizedBox(height: 15),

                Container(
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        colorScheme.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        color:
                            colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.destinationName!,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 25),

              const Text(
                'Choose Service',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: services.map(
                  (service) {
                    final selected =
                        selectedService == service;

                    return ChoiceChip(
                      selected: selected,
                      avatar: Icon(
                        serviceIcon(service),
                        size: 18,
                      ),
                      label: Text(service),
                      onSelected: (_) {
                        setState(() {
                          selectedService =
                              service;

                          priceController.clear();

                          resultTitle = null;
                          resultMessage = null;
                          resultColor = null;
                          resultIcon = null;
                        });
                      },
                    );
                  },
                ).toList(),
              ),

              const SizedBox(height: 25),

              Container(
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration:
                              BoxDecoration(
                            color: colorScheme
                                .primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            serviceIcon(
                              selectedService,
                            ),
                            color:
                                colorScheme.primary,
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
                                selectedService,
                                style:
                                    const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                serviceDescription,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    const Text(
                      'Expected Range',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'EGP $minPrice - EGP $maxPrice',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'What price were you quoted?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  if (resultTitle != null) {
                    resetResult();
                  }
                },
                decoration:
                    InputDecoration(
                  labelText: context.trLiteral('Quoted Price'),
                  hintText: context.trLiteral('Example: 250'),
                  prefixText: 'EGP ',
                  prefixIcon: Icon(
                    Icons.payments_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: checkPrice,
                  icon: const Icon(
                    Icons.price_check,
                  ),
                  label: const Text(
                    'CHECK PRICE',
                  ),
                ),
              ),

              if (resultTitle != null) ...[
                const SizedBox(height: 25),

                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: resultColor!
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: resultColor!
                          .withValues(
                        alpha: 0.40,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        resultIcon,
                        size: 45,
                        color: resultColor,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        resultTitle!,
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          color: resultColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        resultMessage!,
                        textAlign:
                            TextAlign.center,
                        style: const TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 25),

              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme
                      .secondaryContainer,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'These values are prototype estimates only. Actual prices can vary by location, time, service quality and market conditions. We will replace these ranges with verified data sources later.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.5,
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
    );
  }
}