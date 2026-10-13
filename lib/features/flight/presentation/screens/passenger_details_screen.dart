import 'package:flutter/material.dart' hide Text;

import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:egypt_guide/core/widgets/aviation_background.dart';
import 'package:egypt_guide/features/flight/data/models/flight_offer.dart';
import 'package:egypt_guide/features/flight/data/models/flight_seat.dart';
import 'package:egypt_guide/features/flight/data/models/paymob_payment_session.dart';
import 'package:egypt_guide/features/flight/data/services/flight_service.dart';
import 'package:egypt_guide/features/flight/presentation/screens/paymob_payment_screen.dart';
import 'package:egypt_guide/features/flight/presentation/screens/booking_confirmation_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final FlightOffer offer;
  final List<SelectedFlightSeat> selectedSeats;

  const PassengerDetailsScreen({
    super.key,
    required this.offer,
    required this.selectedSeats,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final formKey = GlobalKey<FormState>();
  final FlightService flightService = FlightService();

  late final List<TextEditingController> firstNames;
  late final List<TextEditingController> lastNames;
  late final List<TextEditingController> passportNumbers;
  late final List<TextEditingController> passportCountries;
  late final List<DateTime?> birthDates;
  late final List<DateTime?> passportExpiries;
  late final List<String> genders;

  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool processing = false;

  int get travelers => widget.offer.passengerIds.length;

  @override
  void initState() {
    super.initState();
    firstNames = List.generate(travelers, (_) => TextEditingController());
    lastNames = List.generate(travelers, (_) => TextEditingController());
    passportNumbers = List.generate(travelers, (_) => TextEditingController());
    passportCountries = List.generate(
      travelers,
      (_) => TextEditingController(text: 'EG'),
    );
    birthDates = List<DateTime?>.filled(travelers, null);
    passportExpiries = List<DateTime?>.filled(travelers, null);
    genders = List<String>.filled(travelers, 'f');
  }

  @override
  void dispose() {
    for (final controller in [
      ...firstNames,
      ...lastNames,
      ...passportNumbers,
      ...passportCountries,
    ]) {
      controller.dispose();
    }
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String _date(DateTime? value) {
    if (value == null) return 'Select date';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String _apiDate(DateTime value) {
    return '${value.year}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickBirthDate(int index) async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (value != null && mounted) {
      setState(() => birthDates[index] = value);
    }
  }

  Future<void> _pickPassportExpiry(int index) async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year + 2, now.month, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 15),
    );
    if (value != null && mounted) {
      setState(() => passportExpiries[index] = value);
    }
  }

  List<Map<String, dynamic>> _buildPassengers() {
    return List.generate(travelers, (index) {
      return {
        'id': widget.offer.passengerIds[index],
        'givenName': firstNames[index].text.trim(),
        'familyName': lastNames[index].text.trim(),
        'gender': genders[index],
        'bornOn': _apiDate(birthDates[index]!),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'identityDocuments': [
          {
            'type': 'passport',
            'uniqueIdentifier': passportNumbers[index].text.trim(),
            'issuingCountryCode':
                passportCountries[index].text.trim().toUpperCase(),
            'expiresOn': _apiDate(passportExpiries[index]!),
          },
        ],
      };
    });
  }

  Future<void> continueToPayment() async {
    if (!formKey.currentState!.validate()) return;

    for (var index = 0; index < travelers; index++) {
      if (birthDates[index] == null || passportExpiries[index] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Complete the dates for Passenger ${index + 1}.',
            ),
          ),
        );
        return;
      }
    }

    setState(() => processing = true);

    try {
      final latestOffer = await flightService.refreshOffer(widget.offer.id);

      if (!mounted) return;

      if (latestOffer.currency.toUpperCase() != 'EGP') {
        throw Exception(
          'The live fare is ${latestOffer.totalAmount.toStringAsFixed(2)} '
          '${latestOffer.currency}. Paymob payment must be converted to EGP '
          'by the backend before live booking can be enabled.',
        );
      }

      final nonEgpSeat = widget.selectedSeats.any(
        (seat) => seat.amount > 0 && seat.currency.toUpperCase() != 'EGP',
      );
      if (nonEgpSeat) {
        throw Exception(
          'One or more selected seats are priced in a currency other than EGP. '
          'Currency conversion must be enabled in the backend before live payment.',
        );
      }

      final seatTotal = widget.selectedSeats.fold<double>(
        0,
        (sum, seat) => sum + seat.amount,
      );

      final paymentStatus = await Navigator.push<PaymobPaymentStatus>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymobPaymentScreen(
            amount: latestOffer.totalAmount + seatTotal,
            firstName: firstNames.first.text.trim(),
            lastName: lastNames.first.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            description:
                '${latestOffer.origin} → ${latestOffer.destination} Flight',
          ),
        ),
      );

      if (!mounted || paymentStatus == null || !paymentStatus.isSuccessful) {
        return;
      }

      final booking = await flightService.createBooking(
        offerId: latestOffer.id,
        paymentReference: paymentStatus.reference,
        passengers: _buildPassengers(),
        selectedSeats: widget.selectedSeats,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            booking: booking,
            offer: latestOffer,
            selectedSeats: widget.selectedSeats,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: AviationBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Passenger Details',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          _Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Contact Details',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (value) {
                                    final text = value?.trim() ?? '';
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                        .hasMatch(text)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  validator: (value) {
                                    final digits = (value ?? '')
                                        .replaceAll(RegExp(r'[^0-9]'), '');
                                    return digits.length >= 8
                                        ? null
                                        : 'Enter a valid phone number';
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...List.generate(travelers, (index) {
                            final passengerId = widget.offer.passengerIds[index];
                            SelectedFlightSeat? seat;
                            for (final item in widget.selectedSeats) {
                              if (item.passengerId == passengerId) {
                                seat = item;
                                break;
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Passenger ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (seat != null)
                                          Chip(label: Text('Seat ${seat.designator}')),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: firstNames[index],
                                            decoration: const InputDecoration(
                                              labelText: 'First Name',
                                            ),
                                            validator: _required,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: lastNames[index],
                                            decoration: const InputDecoration(
                                              labelText: 'Last Name',
                                            ),
                                            validator: _required,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      initialValue: genders[index],
                                      decoration: const InputDecoration(
                                        labelText: 'Gender',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'f',
                                          child: Text('Female'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'm',
                                          child: Text('Male'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => genders[index] = value);
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _DateField(
                                      title: 'Date of Birth',
                                      value: _date(birthDates[index]),
                                      onTap: () => _pickBirthDate(index),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: passportNumbers[index],
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            decoration: const InputDecoration(
                                              labelText: 'Passport Number',
                                            ),
                                            validator: _required,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: passportCountries[index],
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            maxLength: 2,
                                            decoration: const InputDecoration(
                                              labelText: 'Country',
                                              counterText: '',
                                            ),
                                            validator: (value) {
                                              return (value?.trim().length == 2)
                                                  ? null
                                                  : '2 letters';
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _DateField(
                                      title: 'Passport Expiry',
                                      value: _date(passportExpiries[index]),
                                      onTap: () => _pickPassportExpiry(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.94),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: processing ? null : continueToPayment,
                        icon: processing
                            ? const SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.lock_outline_rounded),
                        label: Text(
                          processing ? 'PROCESSING...' : 'CONTINUE TO PAYMENT',
                          style: const TextStyle(fontWeight: FontWeight.w900),
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

  static String? _required(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Required' : null;
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _DateField extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}
