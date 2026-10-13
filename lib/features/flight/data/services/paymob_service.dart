import 'dart:convert';

import 'package:http/http.dart'
    as http;

import 'package:egypt_guide/features/flight/data/models/paymob_payment_session.dart';

class PaymobService {
  static const String _baseUrl =
      'https://egypt-guide-api.sohilasamy882006.workers.dev';

  Future<PaymobPaymentSession>
      createPayment({
    required double amount,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String description =
        'Egypt Guide Flight',
  }) async {
    final uri =
        Uri.parse(
      '$_baseUrl/create-payment',
    );

    final response =
        await http.post(
      uri,

      headers: {
        'Content-Type':
            'application/json',
      },

      body:
          jsonEncode(
        {
          'amount':
              amount,

          'firstName':
              firstName,

          'lastName':
              lastName,

          'email':
              email,

          'phone':
              phone,

          'description':
              description,
        },
      ),
    );

    Map<String, dynamic>
        data;

    try {
      data =
          Map<String, dynamic>.from(
        jsonDecode(
          response.body,
        ) as Map,
      );
    } catch (_) {
      throw Exception(
        'Invalid response from payment server.',
      );
    }

    if (
      response.statusCode < 200 ||
      response.statusCode >= 300
    ) {
      throw Exception(
        data['message']
                ?.toString() ??
            'Could not start payment.',
      );
    }

    if (
      data['success'] != true
    ) {
      throw Exception(
        data['message']
                ?.toString() ??
            'Could not start payment.',
      );
    }

    final session =
        PaymobPaymentSession
            .fromJson(
      data,
    );

    if (
      session.reference.isEmpty ||
      session.checkoutUrl.isEmpty
    ) {
      throw Exception(
        'Payment session is incomplete.',
      );
    }

    return session;
  }

  Future<PaymobPaymentStatus>
      getPaymentStatus(
    String reference,
  ) async {
    final uri =
        Uri.parse(
      '$_baseUrl/payment-status',
    ).replace(
      queryParameters: {
        'reference':
            reference,
      },
    );

    final response =
        await http.get(
      uri,
      headers: {
        'Accept':
            'application/json',
      },
    );

    Map<String, dynamic>
        data;

    try {
      data =
          Map<String, dynamic>.from(
        jsonDecode(
          response.body,
        ) as Map,
      );
    } catch (_) {
      throw Exception(
        'Invalid payment status response.',
      );
    }

    if (
      response.statusCode < 200 ||
      response.statusCode >= 300
    ) {
      throw Exception(
        data['message']
                ?.toString() ??
            'Could not check payment.',
      );
    }

    final payment =
        data['payment'];

    if (payment is! Map) {
      throw Exception(
        'Payment status was not returned.',
      );
    }

    return PaymobPaymentStatus
        .fromJson(
      Map<String, dynamic>.from(
        payment,
      ),
    );
  }
}