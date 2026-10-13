import 'package:flutter/material.dart';
import 'package:egypt_guide/features/trip/presentation/screens/payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String from;
  final String to;
  final int travelers;
  final String travelClass;
  final DateTime departureDate;
  final Map<String, dynamic> flight;
  final List<String> selectedSeats;
  final List<Map<String, dynamic>> passengers;

  const PaymentScreen({
    super.key,
    required this.from,
    required this.to,
    required this.travelers,
    required this.travelClass,
    required this.departureDate,
    required this.flight,
    required this.selectedSeats,
    required this.passengers,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final formKey = GlobalKey<FormState>();

  final cardHolderController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  bool isLoading = false;
  bool saveCard = false;

  int get pricePerTraveler {
    final String price =
        widget.flight['price']?.toString() ?? '0';

    final digitsOnly =
        price.replaceAll(RegExp(r'[^0-9]'), '');

    return int.tryParse(digitsOnly) ?? 0;
  }

  int get totalPrice {
    return pricePerTraveler * widget.travelers;
  }

  @override
  void dispose() {
    cardHolderController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();

    super.dispose();
  }

  String formatPrice(int price) {
    final text = price.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;

      buffer.write(text[i]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return 'EGP ${buffer.toString()}';
  }

  Future<void> payNow() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Demo payment only.
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          from: widget.from,
          to: widget.to,
          travelers: widget.travelers,
          travelClass: widget.travelClass,
          departureDate: widget.departureDate,
          flight: widget.flight,
          selectedSeats: widget.selectedSeats,
          passengers: widget.passengers,
          totalPrice: totalPrice,
        ),
      ),
    );
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF61DFF1),
          width: 1.5,
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
                          'Payment',
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
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        8,
                        18,
                        25,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // Booking summary
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(17),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.flight,
                                        color:
                                            Color(0xFF078DF5),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${widget.from} → ${widget.to}',
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 28),

                                  _SummaryRow(
                                    title: 'Airline',
                                    value:
                                        widget.flight['airline']
                                            .toString(),
                                  ),

                                  const SizedBox(height: 10),

                                  _SummaryRow(
                                    title: 'Seats',
                                    value: widget.selectedSeats
                                        .join(', '),
                                  ),

                                  const SizedBox(height: 10),

                                  _SummaryRow(
                                    title: 'Class',
                                    value: widget.travelClass,
                                  ),

                                  const Divider(height: 28),

                                  _SummaryRow(
                                    title:
                                        'Price per traveler',
                                    value: formatPrice(
                                      pricePerTraveler,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  _SummaryRow(
                                    title:
                                        '${widget.travelers} Traveler${widget.travelers > 1 ? 's' : ''}',
                                    value: formatPrice(
                                      totalPrice,
                                    ),
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(17),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(17),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.credit_card,
                                        color:
                                            Color(0xFF078DF5),
                                      ),
                                      SizedBox(width: 9),
                                      Text(
                                        'Credit / Debit Card',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  TextFormField(
                                    controller:
                                        cardHolderController,
                                    textInputAction:
                                        TextInputAction.next,
                                    decoration:
                                        inputDecoration(
                                      label: 'Card Holder',
                                      icon:
                                          Icons.person_outline,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value
                                              .trim()
                                              .isEmpty) {
                                        return 'Card holder name is required';
                                      }

                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 13),

                                  TextFormField(
                                    controller:
                                        cardNumberController,
                                    keyboardType:
                                        TextInputType.number,
                                    textInputAction:
                                        TextInputAction.next,
                                    maxLength: 16,
                                    decoration:
                                        inputDecoration(
                                      label: 'Card Number',
                                      icon:
                                          Icons.credit_card,
                                    ).copyWith(
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      final number =
                                          value
                                                  ?.replaceAll(
                                                ' ',
                                                '',
                                              ) ??
                                              '';

                                      if (number.length !=
                                          16) {
                                        return 'Enter a 16 digit card number';
                                      }

                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 13),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              expiryController,
                                          keyboardType:
                                              TextInputType
                                                  .datetime,
                                          textInputAction:
                                              TextInputAction
                                                  .next,
                                          decoration:
                                              inputDecoration(
                                            label: 'MM/YY',
                                            icon: Icons
                                                .calendar_month_outlined,
                                          ),
                                          validator:
                                              (value) {
                                            if (value ==
                                                    null ||
                                                value
                                                    .trim()
                                                    .isEmpty) {
                                              return 'Required';
                                            }

                                            return null;
                                          },
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              cvvController,
                                          keyboardType:
                                              TextInputType
                                                  .number,
                                          obscureText: true,
                                          maxLength: 4,
                                          decoration:
                                              inputDecoration(
                                            label: 'CVV',
                                            icon: Icons
                                                .lock_outline,
                                          ).copyWith(
                                            counterText: '',
                                          ),
                                          validator:
                                              (value) {
                                            if (value ==
                                                    null ||
                                                value.length <
                                                    3) {
                                              return 'Invalid';
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  CheckboxListTile(
                                    contentPadding:
                                        EdgeInsets.zero,
                                    value: saveCard,
                                    activeColor:
                                        const Color(
                                      0xFF078DF5,
                                    ),
                                    title: const Text(
                                      'Save card for future bookings',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        saveCard =
                                            value ?? false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 15,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Demo payment — no card information is stored',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed:
                                    isLoading ? null : payNow,
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF078DF5,
                                  ),
                                  foregroundColor:
                                      Colors.white,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      25,
                                    ),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'PAY ${formatPrice(totalPrice)}',
                                        style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
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

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: bold
                  ? Colors.black
                  : Colors.grey,
              fontWeight:
                  bold ? FontWeight.bold : null,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight:
                bold ? FontWeight.bold : FontWeight.w600,
            color: bold
                ? const Color(0xFFE63946)
                : Colors.black87,
          ),
        ),
      ],
    );
  }
}