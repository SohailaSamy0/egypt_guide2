class PaymobPaymentSession {
  final String reference;
  final String checkoutUrl;

  final String? intentionId;
  final dynamic orderId;

  final double amount;
  final String currency;

  const PaymobPaymentSession({
    required this.reference,
    required this.checkoutUrl,
    required this.amount,
    required this.currency,
    this.intentionId,
    this.orderId,
  });

  factory PaymobPaymentSession.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymobPaymentSession(
      reference:
          json['reference']?.toString() ?? '',
      checkoutUrl:
          json['checkoutUrl']?.toString() ?? '',
      intentionId:
          json['intentionId']?.toString(),
      orderId:
          json['orderId'],
      amount:
          (json['amount'] as num?)?.toDouble() ?? 0,
      currency:
          json['currency']?.toString() ?? 'EGP',
    );
  }
}


class PaymobPaymentStatus {
  final String reference;
  final String status;

  final String? transactionId;
  final String? orderId;

  final double? amount;
  final int? amountCents;

  final String currency;

  final bool is3DSecure;

  const PaymobPaymentStatus({
    required this.reference,
    required this.status,
    required this.currency,
    required this.is3DSecure,
    this.transactionId,
    this.orderId,
    this.amount,
    this.amountCents,
  });

  factory PaymobPaymentStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymobPaymentStatus(
      reference:
          json['reference']?.toString() ?? '',
      status:
          json['status']?.toString() ?? 'pending',
      transactionId:
          json['transactionId']?.toString(),
      orderId:
          json['orderId']?.toString(),
      amount:
          (json['amount'] as num?)?.toDouble(),
      amountCents:
          (json['amountCents'] as num?)?.toInt(),
      currency:
          json['currency']?.toString() ?? 'EGP',
      is3DSecure:
          json['is3DSecure'] == true,
    );
  }

  bool get isSuccessful {
    return status == 'success';
  }

  bool get isPending {
    return status == 'pending';
  }

  bool get isFailed {
    return status == 'failed' ||
        status == 'voided' ||
        status == 'refunded';
  }
}