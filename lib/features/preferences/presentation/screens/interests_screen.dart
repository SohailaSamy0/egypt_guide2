import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/core/localization/app_localizations.dart';
import 'package:egypt_guide/features/location/presentation/screens/location_permission_screen.dart';
import 'package:egypt_guide/features/preferences/data/services/interests_service.dart';

class InterestsScreen extends StatefulWidget {
  final bool editMode;

  const InterestsScreen({
    super.key,
    this.editMode = false,
  });

  @override
  State<InterestsScreen> createState() =>
      _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final InterestsService interestsService =
      InterestsService();

  final Set<String> selectedInterests = {};

  bool isLoading = true;
  bool isSaving = false;

  final List<_InterestItem> interests = const [
    _InterestItem(
      keyName: 'history',
      icon: Icons.account_balance_outlined,
    ),
    _InterestItem(
      keyName: 'museums',
      icon: Icons.museum_outlined,
    ),
    _InterestItem(
      keyName: 'food',
      icon: Icons.restaurant_outlined,
    ),
    _InterestItem(
      keyName: 'beaches',
      icon: Icons.beach_access_outlined,
    ),
    _InterestItem(
      keyName: 'shopping',
      icon: Icons.shopping_bag_outlined,
    ),
    _InterestItem(
      keyName: 'adventure',
      icon: Icons.hiking_outlined,
    ),
    _InterestItem(
      keyName: 'ancient_egypt',
      icon: Icons.temple_hindu_outlined,
    ),
    _InterestItem(
      keyName: 'culture',
      icon: Icons.theater_comedy_outlined,
    ),
    _InterestItem(
      keyName: 'nature',
      icon: Icons.park_outlined,
    ),
    _InterestItem(
      keyName: 'nightlife',
      icon: Icons.nightlife_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    loadSavedInterests();
  }

  Future<void> loadSavedInterests() async {
    final saved =
        await interestsService.getSelectedInterests();

    if (!mounted) return;

    setState(() {
      selectedInterests.addAll(saved);
      isLoading = false;
    });
  }

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  Future<void> saveAndContinue() async {
    if (selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('choose_one_interest'),
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await interestsService.saveSelectedInterests(
        selectedInterests,
      );

      if (!mounted) return;

      // لو المستخدم داخل يعدل اهتماماته من For You
      if (widget.editMode) {
        Navigator.pop(
          context,
          true,
        );

        return;
      }

      // أول مرة في الـ onboarding
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LocationPermissionScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF0F141A),
                    Color(0xFF15202B),
                    Color(0xFF1A2A36),
                  ]
                : const [
                    Color(0xFF70E2F1),
                    Color(0xFFA7DDF1),
                    Color(0xFF83DEED),
                  ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 650,
                    ),
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Align(
                            alignment:
                                AlignmentDirectional
                                    .centerStart,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .arrow_back_ios_new,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            widget.editMode
                                ? 'Edit Your Interests'
                                : context.tr(
                                    'interests_title',
                                  ),
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            widget.editMode
                                ? 'Update your interests and we will refresh your recommendations.'
                                : context.tr(
                                    'interests_description',
                                  ),
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: theme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 25),

                          Align(
                            alignment:
                                AlignmentDirectional
                                    .centerStart,
                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: theme
                                    .colorScheme
                                    .surface,
                                borderRadius:
                                    BorderRadius
                                        .circular(20),
                              ),
                              child: Text(
                                '${selectedInterests.length} ${context.tr('selected')}',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                  color: theme
                                      .colorScheme
                                      .primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount:
                                interests.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent:
                                  200,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio:
                                  1.25,
                            ),
                            itemBuilder:
                                (context, index) {
                              final item =
                                  interests[index];

                              final selected =
                                  selectedInterests
                                      .contains(
                                item.keyName,
                              );

                              return Material(
                                color: selected
                                    ? theme
                                        .colorScheme
                                        .primaryContainer
                                    : theme
                                        .colorScheme
                                        .surface,
                                borderRadius:
                                    BorderRadius
                                        .circular(18),
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius
                                          .circular(18),
                                  onTap: () {
                                    toggleInterest(
                                      item.keyName,
                                    );
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets
                                            .all(14),
                                    decoration:
                                        BoxDecoration(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        18,
                                      ),
                                      border:
                                          Border.all(
                                        width:
                                            selected
                                                ? 2
                                                : 1,
                                        color: selected
                                            ? theme
                                                .colorScheme
                                                .primary
                                            : theme
                                                .colorScheme
                                                .outlineVariant,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Icon(
                                          item.icon,
                                          size: 33,
                                          color: selected
                                              ? theme
                                                  .colorScheme
                                                  .primary
                                              : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        ),

                                        const SizedBox(
                                          height: 10,
                                        ),

                                        Text(
                                          context.tr(
                                            item.keyName,
                                          ),
                                          textAlign:
                                              TextAlign
                                                  .center,
                                          style:
                                              TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                            color: selected
                                                ? theme
                                                    .colorScheme
                                                    .primary
                                                : null,
                                          ),
                                        ),

                                        if (selected) ...[
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Icon(
                                            Icons
                                                .check_circle,
                                            size: 17,
                                            color: theme
                                                .colorScheme
                                                .primary,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child:
                                ElevatedButton.icon(
                              onPressed: isSaving
                                  ? null
                                  : saveAndContinue,
                              icon: widget.editMode
                                  ? const Icon(
                                      Icons.save_outlined,
                                    )
                                  : const Icon(
                                      Icons
                                          .arrow_forward,
                                    ),
                              label: isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : Text(
                                      widget.editMode
                                          ? 'SAVE INTERESTS'
                                          : context.tr(
                                              'continue',
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
      ),
    );
  }
}

class _InterestItem {
  final String keyName;
  final IconData icon;

  const _InterestItem({
    required this.keyName,
    required this.icon,
  });
}