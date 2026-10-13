import 'package:flutter/material.dart';
import 'package:egypt_guide/features/trip/presentation/screens/payment_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final String from;
  final String to;
  final int travelers;
  final String travelClass;
  final DateTime departureDate;
  final Map<String, dynamic> flight;
  final List<String> selectedSeats;

  const PassengerDetailsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.travelers,
    required this.travelClass,
    required this.departureDate,
    required this.flight,
    required this.selectedSeats,
  });

  @override
  State<PassengerDetailsScreen> createState() =>
      _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState
    extends State<PassengerDetailsScreen> {
  final formKey = GlobalKey<FormState>();

  late List<TextEditingController> firstNameControllers;
  late List<TextEditingController> lastNameControllers;
  late List<TextEditingController> nationalityControllers;
  late List<TextEditingController> passportControllers;

  late List<DateTime?> birthDates;
  late List<DateTime?> passportExpiryDates;

  @override
  void initState() {
    super.initState();

    firstNameControllers = List.generate(
      widget.travelers,
      (_) => TextEditingController(),
    );

    lastNameControllers = List.generate(
      widget.travelers,
      (_) => TextEditingController(),
    );

    nationalityControllers = List.generate(
      widget.travelers,
      (_) => TextEditingController(),
    );

    passportControllers = List.generate(
      widget.travelers,
      (_) => TextEditingController(),
    );

    birthDates = List<DateTime?>.filled(
      widget.travelers,
      null,
    );

    passportExpiryDates = List<DateTime?>.filled(
      widget.travelers,
      null,
    );
  }

  @override
  void dispose() {
    for (final controller in firstNameControllers) {
      controller.dispose();
    }

    for (final controller in lastNameControllers) {
      controller.dispose();
    }

    for (final controller in nationalityControllers) {
      controller.dispose();
    }

    for (final controller in passportControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> selectBirthDate(int index) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(
        now.year - 25,
        now.month,
        now.day,
      ),
      firstDate: DateTime(1920),
      lastDate: now,
    );

    if (date != null) {
      setState(() {
        birthDates[index] = date;
      });
    }
  }

  Future<void> selectPassportExpiry(int index) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(
        now.year + 1,
        now.month,
        now.day,
      ),
      firstDate: now,
      lastDate: DateTime(
        now.year + 15,
        now.month,
        now.day,
      ),
    );

    if (date != null) {
      setState(() {
        passportExpiryDates[index] = date;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void continueToPayment() {
  if (!formKey.currentState!.validate()) {
    return;
  }

  for (int i = 0; i < widget.travelers; i++) {
    if (birthDates[i] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select date of birth for Passenger ${i + 1}.',
          ),
        ),
      );

      return;
    }

    if (passportExpiryDates[i] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select passport expiry date for Passenger ${i + 1}.',
          ),
        ),
      );

      return;
    }
  }

  final passengers =
      List.generate(widget.travelers, (index) {
    return {
      'firstName':
          firstNameControllers[index].text.trim(),
      'lastName':
          lastNameControllers[index].text.trim(),
      'nationality':
          nationalityControllers[index].text.trim(),
      'passportNumber':
          passportControllers[index].text.trim(),
      'birthDate': birthDates[index],
      'passportExpiry':
          passportExpiryDates[index],
      'seat': widget.selectedSeats[index],
    };
  });

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PaymentScreen(
        from: widget.from,
        to: widget.to,
        travelers: widget.travelers,
        travelClass: widget.travelClass,
        departureDate:
            widget.departureDate,
        flight: widget.flight,
        selectedSeats:
            widget.selectedSeats,
        passengers: passengers,
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
                        const Expanded(
                          child: Text(
                            'Passenger Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15),
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
                              '${widget.from} → ${widget.to}',
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            widget.flight['airline']
                                as String,
                            style: const TextStyle(
                              color:
                                  Color(0xFF078DF5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: Form(
                      key: formKey,
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          5,
                          18,
                          20,
                        ),
                        itemCount: widget.travelers,
                        separatorBuilder:
                            (context, index) =>
                                const SizedBox(
                          height: 15,
                        ),
                        itemBuilder:
                            (context, index) {
                          return _buildPassengerCard(
                            index,
                          );
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      8,
                      18,
                      18,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 47,
                      child: ElevatedButton(
                        onPressed:
                            continueToPayment,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF078DF5),
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
                        child: const Text(
                          'CONTINUE TO PAYMENT',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
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

  Widget _buildPassengerCard(int index) {
    final seat = widget.selectedSeats.length > index
        ? widget.selectedSeats[index]
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 37,
                height: 37,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF7FF),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF078DF5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Passenger ${index + 1}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF7FF),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Text(
                  'Seat $seat',
                  style: const TextStyle(
                    color:
                        Color(0xFF078DF5),
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller:
                      firstNameControllers[
                          index],
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      _inputDecoration(
                    'First Name',
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Required';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: TextFormField(
  controller: passportControllers[index],
  textCapitalization: TextCapitalization.characters,
  textInputAction: TextInputAction.next,
  decoration: _inputDecoration(
    'Passport Number',
    Icons.badge_outlined,
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Passport number is required';
    }

    if (value.trim().length < 5) {
      return 'Enter a valid passport number';
    }

    return null;
  },
),
              ),
            ],
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: () {
              selectBirthDate(index);
            },
            borderRadius:
                BorderRadius.circular(9),
            child: InputDecorator(
              decoration: _inputDecoration(
                'Date of Birth',
                Icons.cake_outlined,
              ),
              child: Text(
                formatDate(
                  birthDates[index],
                ),
                style: TextStyle(
                  fontSize: 13,
                  color:
                      birthDates[index] == null
                          ? Colors.grey
                          : Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller:
                nationalityControllers[index],
            textInputAction:
                TextInputAction.next,
            decoration: _inputDecoration(
              'Nationality',
              Icons.public,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Nationality is required';
              }

              return null;
            },
          ),

          const SizedBox(height: 12),

          TextFormField(
  controller: passportControllers[index],
  textCapitalization: TextCapitalization.characters,
  textInputAction: TextInputAction.next,
  decoration: _inputDecoration(
    'Passport Number',
    Icons.badge_outlined,
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Passport number is required';
    }

    if (value.trim().length < 5) {
      return 'Enter a valid passport number';
    }

    return null;
  },
),

          const SizedBox(height: 12),

          InkWell(
            onTap: () {
              selectPassportExpiry(
                index,
              );
            },
            borderRadius:
                BorderRadius.circular(9),
            child: InputDecorator(
              decoration: _inputDecoration(
                'Passport Expiry',
                Icons
                    .calendar_month_outlined,
              ),
              child: Text(
                formatDate(
                  passportExpiryDates[
                      index],
                ),
                style: TextStyle(
                  fontSize: 13,
                  color:
                      passportExpiryDates[
                                  index] ==
                              null
                          ? Colors.grey
                          : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: const Color(0xFF626262),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 13,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF65DDEA),
          width: 1.5,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }
}