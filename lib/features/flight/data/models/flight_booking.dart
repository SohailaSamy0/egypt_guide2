class FlightBooking {
  final String orderId;
  final String bookingReference;
  final String airlineName;
  final String totalAmount;
  final String totalCurrency;
  final bool liveMode;

  const FlightBooking({
    required this.orderId,
    required this.bookingReference,
    required this.airlineName,
    required this.totalAmount,
    required this.totalCurrency,
    required this.liveMode,
  });

  factory FlightBooking.fromJson(Map<String, dynamic> json) {
    return FlightBooking(
      orderId: json['orderId']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      airlineName: json['airlineName']?.toString() ?? '',
      totalAmount: json['totalAmount']?.toString() ?? '',
      totalCurrency: json['totalCurrency']?.toString() ?? '',
      liveMode: json['liveMode'] == true,
    );
  }
}
