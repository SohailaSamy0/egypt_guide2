import 'package:flutter/material.dart' hide Text;

import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:egypt_guide/core/widgets/aviation_background.dart';
import 'package:egypt_guide/features/flight/presentation/screens/select_flight_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final formKey = GlobalKey<FormState>();
  final fromController = TextEditingController(text: 'CAI');
  final toController = TextEditingController();

  DateTime departureDate = DateTime.now().add(const Duration(days: 7));
  String selectedClass = 'Economy';
  int travelers = 1;

  final travelClasses = const [
    'Economy',
    'Premium Economy',
    'Business',
    'First',
  ];

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: departureDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (value != null && mounted) {
      setState(() => departureDate = value);
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void swapAirports() {
    final from = fromController.text;
    setState(() {
      fromController.text = toController.text;
      toController.text = from;
    });
  }

  void searchFlights() {
    if (!formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectFlightScreen(
          from: fromController.text.trim().toUpperCase(),
          to: toController.text.trim().toUpperCase(),
          departureDate: departureDate,
          travelers: travelers,
          travelClass: selectedClass,
        ),
      ),
    );
  }

  String? validateAirport(String? value) {
    final code = value?.trim().toUpperCase() ?? '';
    if (code.length != 3 || !RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
      return 'Use a 3-letter airport code, e.g. CAI';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: AviationBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Search Flights',
                                  style: TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Choose route, date and passengers',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _GlassCard(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: fromController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'From',
                                hintText: 'CAI',
                                prefixIcon: Icon(Icons.flight_takeoff_rounded),
                              ),
                              validator: validateAirport,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.center,
                              child: IconButton.filled(
                                onPressed: swapAirports,
                                icon: const Icon(Icons.swap_vert_rounded),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: toController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'To',
                                hintText: 'DXB',
                                prefixIcon: Icon(Icons.flight_land_rounded),
                              ),
                              validator: (value) {
                                final error = validateAirport(value);
                                if (error != null) return error;
                                if (value!.trim().toUpperCase() ==
                                    fromController.text.trim().toUpperCase()) {
                                  return 'Destination must be different';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _GlassCard(
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.calendar_month_rounded),
                              title: const Text('Departure'),
                              subtitle: Text(formatDate(departureDate)),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: selectDate,
                            ),
                            const Divider(),
                            DropdownButtonFormField<String>(
                              initialValue: selectedClass,
                              decoration: const InputDecoration(
                                labelText: 'Travel Class',
                                prefixIcon: Icon(Icons.airline_seat_recline_normal),
                              ),
                              items: travelClasses
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedClass = value);
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Travelers',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                IconButton.filledTonal(
                                  onPressed: travelers > 1
                                      ? () => setState(() => travelers--)
                                      : null,
                                  icon: const Icon(Icons.remove),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    '$travelers',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                IconButton.filled(
                                  onPressed: travelers < 9
                                      ? () => setState(() => travelers++)
                                      : null,
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: searchFlights,
                          icon: const Icon(Icons.search_rounded),
                          label: const Text(
                            'SEARCH FLIGHTS',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Results are shown inside Egypt Guide. Prices and schedules come from the connected flight provider.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.72),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
