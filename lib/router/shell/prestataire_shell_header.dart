import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../features/auth/providers/auth_notifier.dart';
import '../../features/home/providers/home_profile_provider.dart';
import '../../features/prestataire/providers/current_prestataire_provider.dart';
import '../../shared/theme/prototype_layout.dart';
import '../../shared/theme/prototype_palette.dart';

/// En-tête image + dégradé (hub prestataire Madbeauty_flutter).
class PrestataireShellHeader extends ConsumerWidget {
  const PrestataireShellHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = PrototypeLayout(context);
    final rem = layout.rem;

    final profileAsync = ref.watch(homeProfileSnapshotProvider);
    final prestataireAsync = ref.watch(currentPrestataireProvider);
    final authUser = ref.watch(authNotifierProvider).value;

    final displayName = switch (profileAsync) {
      AsyncData(:final value) when value != null && value.displayName.isNotEmpty =>
        value.displayName,
      _ => (authUser?.userMetadata?['full_name'] as String?)?.trim() ?? '',
    };
    final salonName = switch (prestataireAsync) {
      AsyncData(:final value) when value?.nomSalon?.trim().isNotEmpty == true =>
        value!.nomSalon!.trim(),
      _ => '',
    };
    final greeting = displayName.isNotEmpty
        ? 'Bonjour ${displayName.split(' ').first}'
        : DiscNav.prestDashboard;

    return SizedBox(
      height: rem * 38,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D1810), PrototypePalette.navDark],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.40),
                  PrototypePalette.navDark.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(rem * 4, rem * 2, rem * 2, rem * 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: rem * 14,
                        height: rem * 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: PrototypePalette.gold, width: 2.5),
                          color: PrototypePalette.brownMid,
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          color: PrototypePalette.gold,
                          size: rem * 8,
                        ),
                      ),
                      SizedBox(width: rem * 3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    greeting,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: rem * 5.2,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x73000000),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(' 👋', style: TextStyle(fontSize: rem * 4.5)),
                              ],
                            ),
                            SizedBox(height: rem * 0.8),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    salonName.isNotEmpty
                                        ? salonName
                                        : DiscNav.prestHub,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: rem * 3.2,
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: rem * 1.5),
                                Icon(
                                  Icons.verified_rounded,
                                  color: PrototypePalette.gold,
                                  size: rem * 4,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: rem * 6,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
