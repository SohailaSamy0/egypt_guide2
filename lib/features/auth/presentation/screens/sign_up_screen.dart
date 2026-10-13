import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/core/localization/app_localizations.dart';
import 'package:egypt_guide/core/widgets/aviation_background.dart';
import 'package:egypt_guide/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:egypt_guide/features/auth/presentation/screens/verify_email_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.trLiteral('Password is required');
    }
    if (value.length < 8) {
      return context.trLiteral('Password must be at least 8 characters');
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return context.trLiteral('Add at least one uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return context.trLiteral('Add at least one lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return context.trLiteral('Add at least one number');
    }
    return null;
  }

  Future<void> createAccount() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await credential.user?.updateDisplayName(nameController.text.trim());
      await credential.user?.sendEmailVerification();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      var message = 'Something went wrong. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'This email already has an account.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'network-request-failed') {
        message = 'Check your internet connection.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: AviationBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Create\nan account',
                        style: TextStyle(
                          fontSize: 32,
                          height: 1.02,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Build your Egypt journey around your interests, trips and saved places.',
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.72),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.name],
                                decoration: InputDecoration(
                                  labelText: context.trLiteral('Full Name'),
                                  prefixIcon: const Icon(Icons.person_outline_rounded),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().length < 2) {
                                    return context.trLiteral('Enter a valid name');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 13),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                  labelText: context.trLiteral('Email Address'),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.trLiteral('Email is required');
                                  }
                                  if (!isValidEmail(value.trim())) {
                                    return context.trLiteral('Enter a valid email address');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 13),
                              TextFormField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.newPassword],
                                decoration: InputDecoration(
                                  labelText: context.trLiteral('Password'),
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() => obscurePassword = !obscurePassword);
                                    },
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: validatePassword,
                              ),
                              const SizedBox(height: 13),
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => createAccount(),
                                decoration: InputDecoration(
                                  labelText: context.trLiteral('Confirm Password'),
                                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureConfirmPassword =
                                            !obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context.trLiteral('Confirm your password');
                                  }
                                  if (value != passwordController.text) {
                                    return context.trLiteral('Passwords do not match');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton.icon(
                                  onPressed: isLoading ? null : createAccount,
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 19,
                                          height: 19,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.person_add_alt_1_rounded),
                                  label: const Text('Create Account'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already Have an Account? '),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const SignInScreen()),
                              );
                            },
                            child: const Text('Login'),
                          ),
                        ],
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
