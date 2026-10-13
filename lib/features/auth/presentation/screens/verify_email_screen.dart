import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/core/widgets/aviation_background.dart';
import 'package:egypt_guide/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:egypt_guide/features/onboarding/presentation/screens/trip_status_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isChecking = false;
  bool canResend = false;
  int secondsRemaining = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    setState(() {
      canResend = false;
      secondsRemaining = 60;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          secondsRemaining = 0;
          canResend = true;
        });
        return;
      }
      setState(() => secondsRemaining--);
    });
  }

  Future<void> checkVerification() async {
    setState(() => isChecking = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (!mounted) return;

      if (user != null && user.emailVerified) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TripStatusScreen()),
          (_) => false,
        );
      } else {
        _show('Your email is not verified yet. Please check your inbox.');
      }
    } catch (_) {
      if (mounted) _show('Could not check verification. Please try again.');
    } finally {
      if (mounted) setState(() => isChecking = false);
    }
  }

  Future<void> resendEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (!mounted) return;
      startTimer();
      _show('Verification email sent again.');
    } on FirebaseAuthException catch (e) {
      if (mounted) _show(e.message ?? 'Could not resend verification email.');
    }
  }

  Future<void> useAnotherAccount() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      body: AviationBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(31),
                      ),
                      child: Icon(
                        Icons.mark_email_unread_rounded,
                        size: 50,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Verify\nyour email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Open your email and press the verification link. Then return to the app and continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    if (email.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          email,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: isChecking ? null : checkVerification,
                        icon: isChecking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.verified_rounded),
                        label: const Text('I Verified My Email'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: canResend ? resendEmail : null,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          canResend
                              ? 'Resend verification email'
                              : 'Resend in $secondsRemaining s',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: useAnotherAccount,
                      icon: const Icon(Icons.switch_account_rounded),
                      label: const Text('Use another account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
