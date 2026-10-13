import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:egypt_guide/features/flight/data/models/paymob_payment_session.dart';
import 'package:egypt_guide/features/flight/data/services/paymob_service.dart';

class PaymobPaymentScreen
    extends StatefulWidget {
  final double amount;

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  final String description;

  const PaymobPaymentScreen({
    super.key,
    required this.amount,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.description =
        'Egypt Guide Flight',
  });

  @override
  State<PaymobPaymentScreen>
      createState() =>
          _PaymobPaymentScreenState();
}


class _PaymobPaymentScreenState
    extends State<PaymobPaymentScreen> {
  final PaymobService
      paymobService =
      PaymobService();

  PaymobPaymentSession?
      session;

  PaymobPaymentStatus?
      paymentStatus;

  Timer? pollingTimer;

  bool creatingPayment =
      false;

  bool checkingPayment =
      false;

  String? errorMessage;

  int pollingAttempts = 0;

  static const int
      maxPollingAttempts = 90;


  @override
  void dispose() {
    pollingTimer?.cancel();

    super.dispose();
  }


  Future<void>
      startPayment() async {
    if (creatingPayment) {
      return;
    }

    setState(() {
      creatingPayment =
          true;

      errorMessage =
          null;

      paymentStatus =
          null;
    });

    try {
      final payment =
          await paymobService
              .createPayment(
        amount:
            widget.amount,

        firstName:
            widget.firstName,

        lastName:
            widget.lastName,

        email:
            widget.email,

        phone:
            widget.phone,

        description:
            widget.description,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        session =
            payment;
      });

      final uri =
          Uri.parse(
        payment.checkoutUrl,
      );

      final launched =
          await launchUrl(
        uri,

        mode:
            kIsWeb
                ? LaunchMode
                    .platformDefault
                : LaunchMode
                    .externalApplication,
      );

      if (!launched) {
        throw Exception(
          'Could not open Paymob Checkout.',
        );
      }

      startPolling();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage =
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    } finally {
      if (mounted) {
        setState(() {
          creatingPayment =
              false;
        });
      }
    }
  }


  void startPolling() {
    pollingTimer
        ?.cancel();

    pollingAttempts = 0;

    pollingTimer =
        Timer.periodic(
      const Duration(
        seconds: 4,
      ),
      (_) {
        pollingAttempts++;

        checkPaymentStatus(
          silent: true,
        );

        if (
          pollingAttempts >=
          maxPollingAttempts
        ) {
          pollingTimer
              ?.cancel();
        }
      },
    );
  }


  Future<void>
      checkPaymentStatus({
    bool silent = false,
  }) async {
    final currentSession =
        session;

    if (
      currentSession == null ||
      checkingPayment
    ) {
      return;
    }

    if (!silent &&
        mounted) {
      setState(() {
        checkingPayment =
            true;

        errorMessage =
            null;
      });
    }

    try {
      final status =
          await paymobService
              .getPaymentStatus(
        currentSession
            .reference,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        paymentStatus =
            status;
      });

      if (
        status.isSuccessful
      ) {
        pollingTimer
            ?.cancel();
      }

      if (
        status.isFailed
      ) {
        pollingTimer
            ?.cancel();
      }
    } catch (error) {
      if (
        !silent &&
        mounted
      ) {
        setState(() {
          errorMessage =
              error
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  );
        });
      }
    } finally {
      if (
        !silent &&
        mounted
      ) {
        setState(() {
          checkingPayment =
              false;
        });
      }
    }
  }


  Future<void>
      reopenCheckout() async {
    final currentSession =
        session;

    if (currentSession ==
        null) {
      return;
    }

    await launchUrl(
      Uri.parse(
        currentSession
            .checkoutUrl,
      ),

      mode:
          kIsWeb
              ? LaunchMode
                  .platformDefault
              : LaunchMode
                  .externalApplication,
    );
  }


  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    final status =
        paymentStatus;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Secure Payment',
        ),
      ),

      body:
          SafeArea(
        child: Center(
          child:
              ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 560,
            ),

            child:
                ListView(
              padding:
                  const EdgeInsets.all(
                20,
              ),

              children: [
                Container(
                  padding:
                      const EdgeInsets.all(
                    22,
                  ),

                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      colors: [
                        colorScheme
                            .primaryContainer,

                        colorScheme
                            .secondaryContainer,
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),

                  child:
                      Column(
                    children: [
                      Icon(
                        Icons
                            .flight_takeoff_rounded,

                        size:
                            46,

                        color:
                            colorScheme
                                .primary,
                      ),

                      const SizedBox(
                        height:
                            14,
                      ),

                      Text(
                        widget
                            .description,

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          fontSize:
                              20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height:
                            12,
                      ),

                      Text(
                        '${widget.amount.toStringAsFixed(2)} EGP',

                        style:
                            TextStyle(
                          fontSize:
                              28,

                          fontWeight:
                              FontWeight.bold,

                          color:
                              colorScheme
                                  .primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height:
                      24,
                ),

                _SecurityCard(
                  icon:
                      Icons
                          .verified_user_outlined,

                  title:
                      'Secure checkout',

                  description:
                      'Card details are entered directly in Paymob Checkout. Egypt Guide does not store your card number or CVV.',
                ),

                const SizedBox(
                  height:
                      12,
                ),

                _SecurityCard(
                  icon:
                      Icons
                          .lock_outline,

                  title:
                      'Payment verification',

                  description:
                      'Egypt Guide confirms the transaction with the payment server before marking it successful.',
                ),

                const SizedBox(
                  height:
                      24,
                ),

                if (errorMessage !=
                    null)
                  Container(
                    margin:
                        const EdgeInsets.only(
                      bottom:
                          16,
                    ),

                    padding:
                        const EdgeInsets.all(
                      14,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          colorScheme
                              .errorContainer,

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child:
                        Text(
                      errorMessage!,
                      style:
                          TextStyle(
                        color:
                            colorScheme
                                .onErrorContainer,
                      ),
                    ),
                  ),

                if (session ==
                    null)
                  SizedBox(
                    height:
                        54,

                    child:
                        FilledButton.icon(
                      onPressed:
                          creatingPayment
                              ? null
                              : startPayment,

                      icon:
                          creatingPayment
                              ? const SizedBox(
                                  width:
                                      20,
                                  height:
                                      20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .payment,
                                ),

                      label:
                          Text(
                        creatingPayment
                            ? 'PREPARING CHECKOUT...'
                            : 'PAY SECURELY',
                      ),
                    ),
                  ),

                if (session !=
                    null &&
                    (status ==
                            null ||
                        status
                            .isPending))
                  _PendingPaymentCard(
                    reference:
                        session!
                            .reference,

                    checking:
                        checkingPayment,

                    onCheck:
                        () =>
                            checkPaymentStatus(),

                    onOpen:
                        reopenCheckout,
                  ),

                if (status !=
                        null &&
                    status
                        .isSuccessful)
                  _SuccessfulPaymentCard(
                    status:
                        status,

                    onContinue:
                        () {
                      Navigator.pop(
                        context,
                        status,
                      );
                    },
                  ),

                if (status !=
                        null &&
                    status
                        .isFailed)
                  _FailedPaymentCard(
                    status:
                        status,

                    onRetry:
                        () {
                      pollingTimer
                          ?.cancel();

                      setState(() {
                        session =
                            null;

                        paymentStatus =
                            null;

                        errorMessage =
                            null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _SecurityCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityCard({
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
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color:
                colorScheme
                    .primary,
          ),

          const SizedBox(
            width:
                12,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height:
                      4,
                ),

                Text(
                  description,

                  style:
                      TextStyle(
                    color:
                        colorScheme
                            .onSurfaceVariant,

                    fontSize:
                        13,
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


class _PendingPaymentCard
    extends StatelessWidget {
  final String reference;

  final bool checking;

  final VoidCallback onCheck;

  final VoidCallback onOpen;

  const _PendingPaymentCard({
    required this.reference,
    required this.checking,
    required this.onCheck,
    required this.onOpen,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        const CircularProgressIndicator(),

        const SizedBox(
          height:
              16,
        ),

        const Text(
          'Waiting for payment confirmation...',
          textAlign:
              TextAlign.center,

          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,

            fontSize:
                17,
          ),
        ),

        const SizedBox(
          height:
              8,
        ),

        const Text(
          'Complete the payment in Paymob Checkout, then return to Egypt Guide.',
          textAlign:
              TextAlign.center,
        ),

        const SizedBox(
          height:
              18,
        ),

        OutlinedButton.icon(
          onPressed:
              onOpen,

          icon:
              const Icon(
            Icons
                .open_in_browser,
          ),

          label:
              const Text(
            'OPEN CHECKOUT',
          ),
        ),

        const SizedBox(
          height:
              8,
        ),

        FilledButton.icon(
          onPressed:
              checking
                  ? null
                  : onCheck,

          icon:
              checking
                  ? const SizedBox(
                      width:
                          18,
                      height:
                          18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                      ),
                    )
                  : const Icon(
                      Icons.refresh,
                    ),

          label:
              const Text(
            'CHECK PAYMENT',
          ),
        ),

        const SizedBox(
          height:
              14,
        ),

        Text(
          'Reference: $reference',

          textAlign:
              TextAlign.center,

          style:
              const TextStyle(
            fontSize:
                11,
          ),
        ),
      ],
    );
  }
}


class _SuccessfulPaymentCard
    extends StatelessWidget {
  final PaymobPaymentStatus
      status;

  final VoidCallback
      onContinue;

  const _SuccessfulPaymentCard({
    required this.status,
    required this.onContinue,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        const Icon(
          Icons
              .check_circle,

          size:
              72,

          color:
              Colors.green,
        ),

        const SizedBox(
          height:
              16,
        ),

        const Text(
          'Payment Confirmed',

          style:
              TextStyle(
            fontSize:
                23,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height:
              8,
        ),

        Text(
          status.transactionId ==
                  null
              ? 'Your payment was verified successfully.'
              : 'Transaction: ${status.transactionId}',

          textAlign:
              TextAlign.center,
        ),

        const SizedBox(
          height:
              24,
        ),

        SizedBox(
          width:
              double.infinity,

          height:
              52,

          child:
              FilledButton(
            onPressed:
                onContinue,

            child:
                const Text(
              'CONTINUE',
            ),
          ),
        ),
      ],
    );
  }
}


class _FailedPaymentCard
    extends StatelessWidget {
  final PaymobPaymentStatus
      status;

  final VoidCallback onRetry;

  const _FailedPaymentCard({
    required this.status,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        const Icon(
          Icons
              .cancel_outlined,

          size:
              70,

          color:
              Colors.red,
        ),

        const SizedBox(
          height:
              15,
        ),

        Text(
          status.status ==
                  'refunded'
              ? 'Payment Refunded'
              : status.status ==
                      'voided'
                  ? 'Payment Voided'
                  : 'Payment Failed',

          style:
              const TextStyle(
            fontSize:
                22,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height:
              20,
        ),

        FilledButton.icon(
          onPressed:
              onRetry,

          icon:
              const Icon(
            Icons.refresh,
          ),

          label:
              const Text(
            'TRY AGAIN',
          ),
        ),
      ],
    );
  }
}