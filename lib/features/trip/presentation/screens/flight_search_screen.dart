import 'package:flutter/material.dart';
import 'package:egypt_guide/features/trip/presentation/screens/select_flight_screen.dart';
class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() =>
      _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final formKey = GlobalKey<FormState>();

  final fromController = TextEditingController();
  final toController = TextEditingController();

  String tripType = 'One way';
  String selectedClass = 'Economy';

  DateTime? departureDate;
  DateTime? returnDate;

  int travelers = 1;

  final List<String> travelClasses = [
    'Economy',
    'Premium Economy',
    'Business',
    'First',
  ];

  Future<void> selectDepartureDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );

    if (selected != null) {
      setState(() {
        departureDate = selected;

        if (returnDate != null &&
            returnDate!.isBefore(selected)) {
          returnDate = null;
        }
      });
    }
  }

  Future<void> selectReturnDate() async {
    final firstDate = departureDate ??
        DateTime.now().add(
          const Duration(days: 1),
        );

    final selected = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ),
    );

    if (selected != null) {
      setState(() {
        returnDate = selected;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Add date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void swapLocations() {
    final from = fromController.text;

    setState(() {
      fromController.text = toController.text;
      toController.text = from;
    });
  }

  void searchFlights() {
  if (!formKey.currentState!.validate()) {
    return;
  }

  if (departureDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please choose your departure date.',
        ),
      ),
    );
    return;
  }

  if (tripType == 'Round' && returnDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please choose your return date.',
        ),
      ),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SelectFlightScreen(
        from: fromController.text.trim(),
        to: toController.text.trim(),
        departureDate: departureDate!,
        travelers: travelers,
        travelClass: selectedClass,
      ),
    ),
  );
}

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF80E2F0),

      bottomNavigationBar: SizedBox(
        height: 64,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Container(
              color: const Color(0xFF078DF5),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _BottomItem(
                    icon: Icons.home_outlined,
                    text: 'Home',
                    selected: true,
                  ),
                  _BottomItem(
                    icon: Icons.calendar_month_outlined,
                    text: 'Booking',
                  ),
                  _BottomItem(
                    icon: Icons.local_offer_outlined,
                    text: 'Offer',
                  ),
                  _BottomItem(
                    icon: Icons.mail_outline,
                    text: 'Inbox',
                  ),
                  _BottomItem(
                    icon: Icons.person_outline,
                    text: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  14,
                  14,
                  25,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Container(
                        height: 43,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius:
                              BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor:
                                  Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Egypt Guide',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.notifications_none,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Trip Type
                      Container(
                        height: 35,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            _TripTypeButton(
                              title: 'One way',
                              selected:
                                  tripType == 'One way',
                              onTap: () {
                                setState(() {
                                  tripType = 'One way';
                                  returnDate = null;
                                });
                              },
                            ),
                            _TripTypeButton(
                              title: 'Round',
                              selected:
                                  tripType == 'Round',
                              onTap: () {
                                setState(() {
                                  tripType = 'Round';
                                });
                              },
                            ),
                            _TripTypeButton(
                              title: 'Multi-city',
                              selected:
                                  tripType == 'Multi-city',
                              onTap: () {
                                setState(() {
                                  tripType = 'Multi-city';
                                });

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Multi-city booking will be added later.',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Main Search Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: [
                                    _LocationField(
                                      label: 'From',
                                      hint:
                                          'City or departure airport',
                                      controller:
                                          fromController,
                                      icon:
                                          Icons.flight_takeoff,
                                      validator: (value) {
                                        if (value == null ||
                                            value
                                                .trim()
                                                .isEmpty) {
                                          return 'Enter departure city';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),

                                    _LocationField(
                                      label: 'To',
                                      hint:
                                          'City or airport in Egypt',
                                      controller:
                                          toController,
                                      icon:
                                          Icons.flight_land,
                                      validator: (value) {
                                        if (value == null ||
                                            value
                                                .trim()
                                                .isEmpty) {
                                          return 'Enter destination';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),

                                Positioned(
                                  right: 8,
                                  child: InkWell(
                                    onTap: swapLocations,
                                    borderRadius:
                                        BorderRadius.circular(
                                      25,
                                    ),
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration:
                                          const BoxDecoration(
                                        color:
                                            Color(0xFF65DDEA),
                                        shape:
                                            BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.swap_vert,
                                        size: 22,
                                        color:
                                            Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _SmallInfoBox(
                                    title: 'Departure',
                                    value: formatDate(
                                      departureDate,
                                    ),
                                    icon: Icons
                                        .calendar_month_outlined,
                                    onTap:
                                        selectDepartureDate,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: _SmallInfoBox(
                                    title: 'Return',
                                    value: tripType ==
                                            'Round'
                                        ? formatDate(
                                            returnDate,
                                          )
                                        : 'One way',
                                    icon: Icons
                                        .calendar_month_outlined,
                                    onTap: tripType ==
                                            'Round'
                                        ? selectReturnDate
                                        : null,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: _TravelerSelector(
                                    travelers: travelers,
                                    onMinus: travelers > 1
                                        ? () {
                                            setState(() {
                                              travelers--;
                                            });
                                          }
                                        : null,
                                    onPlus: travelers < 9
                                        ? () {
                                            setState(() {
                                              travelers++;
                                            });
                                          }
                                        : null,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child:
                                      DropdownButtonFormField<
                                          String>(
                                    initialValue:
                                        selectedClass,
                                    isExpanded: true,
                                    decoration:
                                        InputDecoration(
                                      labelText: 'Class',
                                      labelStyle:
                                          const TextStyle(
                                        fontSize: 11,
                                      ),
                                      filled: true,
                                      fillColor:
                                          Colors.white,
                                      contentPadding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      border:
                                          OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          8,
                                        ),
                                        borderSide:
                                            const BorderSide(
                                          color: Color(
                                            0xFFE1E1E1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    items: travelClasses
                                        .map(
                                          (
                                            travelClass,
                                          ) =>
                                              DropdownMenuItem(
                                            value:
                                                travelClass,
                                            child: Text(
                                              travelClass,
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value ==
                                          null) {
                                        return;
                                      }

                                      setState(() {
                                        selectedClass =
                                            value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              height: 43,
                              child: ElevatedButton(
                                onPressed:
                                    searchFlights,
                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF63DDEA,
                                  ),
                                  foregroundColor:
                                      Colors.white,
                                  elevation: 3,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      22,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'SEARCH FLIGHTS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Divider(
                        color: Colors.white70,
                      ),

                      const SizedBox(height: 7),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          const Text(
                            'Hot offer',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Color(0xFF078DF5),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 92,
                        child: ListView(
                          scrollDirection:
                              Axis.horizontal,
                          children: const [
                            _OfferCard(
                              iconText: '●',
                              percentage: '25% OFF',
                              description:
                                  '25% discount\nwith mastercard',
                            ),
                            SizedBox(width: 10),
                            _OfferCard(
                              iconText: 'VISA',
                              percentage: '33% OFF',
                              description:
                                  'Save more on\nyour flight',
                            ),
                            SizedBox(width: 10),
                            _OfferCard(
                              iconText: '✈',
                              percentage: '15% OFF',
                              description:
                                  'Special travel\noffer',
                            ),
                          ],
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

class _TripTypeButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TripTypeButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF65DDEA)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: selected
                  ? Colors.white
                  : Colors.grey,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?) validator;

  const _LocationField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontSize: 11,
        ),
        hintStyle: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(
          icon,
          size: 19,
          color: Colors.black54,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFE1E1E1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF65DDEA),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class _SmallInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallInfoBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE1E1E1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: Colors.black54,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelerSelector extends StatelessWidget {
  final int travelers;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const _TravelerSelector({
    required this.travelers,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE1E1E1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Text(
                  'Traveller',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '$travelers Adult',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(),
            onPressed: onMinus,
            icon: const Icon(
              Icons.remove,
              size: 15,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(),
            onPressed: onPlus,
            icon: const Icon(
              Icons.add,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String iconText;
  final String percentage;
  final String description;

  const _OfferCard({
    required this.iconText,
    required this.percentage,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 195,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF7E8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  iconText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  percentage,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;

  const _BottomItem({
    required this.icon,
    required this.text,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 21,
          color: selected
              ? Colors.white
              : Colors.white70,
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 9,
            color: selected
                ? Colors.white
                : Colors.white70,
          ),
        ),
      ],
    );
  }
}