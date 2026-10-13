import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';
import 'package:egypt_guide/core/localization/app_localizations.dart';

import 'package:egypt_guide/core/widgets/aviation_background.dart';
import 'package:egypt_guide/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:egypt_guide/features/home/presentation/screens/favorites_screen.dart';
import 'package:egypt_guide/features/preferences/presentation/screens/interests_screen.dart';
import 'package:egypt_guide/features/profile/data/services/user_profile_service.dart';
import 'package:egypt_guide/features/settings/presentation/screens/settings_screen.dart';
import 'package:egypt_guide/features/trips/presentation/screens/my_trips_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final UserProfileService profileService = UserProfileService();

  bool isLoading = true;
  bool isUpdatingName = false;
  bool isLoggingOut = false;

  User? get user => auth.currentUser;

  @override
  void initState() {
    super.initState();
    prepareProfile();
  }

  Future<void> prepareProfile() async {
    try {
      await profileService.ensureUserProfile();
    } catch (_) {
      // The Firebase Auth profile can still be shown if Firestore is offline.
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String get userName {
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user?.email ?? '';
    if (email.contains('@')) return email.split('@').first;
    return 'Traveler';
  }

  String get userEmail => user?.email ?? 'No email available';

  String get initials {
    final parts = userName
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'T';
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  Future<void> editName() async {
    final controller = TextEditingController(text: user?.displayName ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: context.trLiteral('Display Name'),
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                controller.text.trim(),
              ),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (result == null || result.isEmpty) return;

    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    setState(() => isUpdatingName = true);

    try {
      await currentUser.updateDisplayName(result);
      await profileService.updateName(result);
      await currentUser.reload();

      if (!mounted) return;
      setState(() {});
      _showMessage('Name updated.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage(e.message ?? 'Could not update name.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not update name.');
    } finally {
      if (mounted) setState(() => isUpdatingName = false);
    }
  }

  Future<void> refreshAccount() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    try {
      await currentUser.reload();
      await profileService.ensureUserProfile();
      if (!mounted) return;
      setState(() {});
      _showMessage('Account refreshed.');
    } catch (_) {
      if (mounted) _showMessage('Could not refresh account.');
    }
  }

  Future<void> sendVerificationEmail() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    if (currentUser.emailVerified) {
      _showMessage('Email is already verified.');
      return;
    }

    try {
      await currentUser.sendEmailVerification();
      if (mounted) _showMessage('Verification email sent.');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showMessage(e.message ?? 'Could not send verification email.');
      }
    }
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.logout_rounded),
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('LOG OUT'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    setState(() => isLoggingOut = true);

    try {
      await auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() => isLoggingOut = false);
        _showMessage('Could not log out. Please try again.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void openTrips() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyTripsScreen()),
      );

  void openFavorites() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FavoritesScreen()),
      );

  void openInterests() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const InterestsScreen(editMode: true),
        ),
      );

  void openSettings() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: AviationBackground(
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
                  ? const Center(child: Text('No signed-in user.'))
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                          children: [
                            Row(
                              children: [
                                IconButton.filledTonal(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Profile',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                IconButton.filledTonal(
                                  onPressed: refreshAccount,
                                  tooltip: 'Refresh',
                                  icon: const Icon(Icons.refresh_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CircleAvatar(
                                          radius: 52,
                                          backgroundColor: colors.primaryContainer,
                                          child: isUpdatingName
                                              ? const CircularProgressIndicator()
                                              : Text(
                                                  initials,
                                                  style: TextStyle(
                                                    fontSize: 31,
                                                    fontWeight: FontWeight.w900,
                                                    color: colors.primary,
                                                  ),
                                                ),
                                        ),
                                        PositionedDirectional(
                                          end: -4,
                                          bottom: -3,
                                          child: IconButton.filled(
                                            onPressed: editName,
                                            icon: const Icon(Icons.edit_rounded, size: 17),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      userName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userEmail,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Chip(
                                      avatar: Icon(
                                        user!.emailVerified
                                            ? Icons.verified_rounded
                                            : Icons.mark_email_unread_outlined,
                                        size: 18,
                                        color: user!.emailVerified
                                            ? const Color(0xFF00A76F)
                                            : colors.tertiary,
                                      ),
                                      label: Text(
                                        user!.emailVerified
                                            ? 'Verified Email'
                                            : 'Email Not Verified',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Travel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _ProfileTile(
                              icon: Icons.luggage_rounded,
                              title: 'My Trips',
                              subtitle: 'Plan and manage your trips',
                              onTap: openTrips,
                            ),
                            _ProfileTile(
                              icon: Icons.favorite_rounded,
                              title: 'Favorites',
                              subtitle: 'Places you saved',
                              onTap: openFavorites,
                            ),
                            _ProfileTile(
                              icon: Icons.auto_awesome_rounded,
                              title: 'My Interests',
                              subtitle: 'Personalize recommendations',
                              onTap: openInterests,
                            ),
                            _ProfileTile(
                              icon: Icons.settings_rounded,
                              title: 'Settings',
                              subtitle: 'Language and theme',
                              onTap: openSettings,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _ProfileTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Display Name',
                              subtitle: userName,
                              onTap: editName,
                            ),
                            _ProfileTile(
                              icon: Icons.email_outlined,
                              title: 'Email Address',
                              subtitle: userEmail,
                            ),
                            if (!user!.emailVerified)
                              _ProfileTile(
                                icon: Icons.mark_email_unread_outlined,
                                title: 'Verify Email',
                                subtitle: 'Send verification email',
                                onTap: sendVerificationEmail,
                              ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: isLoggingOut ? null : logout,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.error,
                                  side: BorderSide(
                                    color: colors.error.withValues(alpha: 0.45),
                                  ),
                                ),
                                icon: isLoggingOut
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.logout_rounded),
                                label: Text(
                                  isLoggingOut ? 'LOGGING OUT...' : 'LOG OUT',
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

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: colors.surface.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
