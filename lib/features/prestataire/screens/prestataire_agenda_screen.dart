import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/widgets/role_switch_section.dart';

/// Agenda prestataire (créneaux et réservations) — à enrichir.
class PrestataireAgendaScreen extends StatelessWidget {
  const PrestataireAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(DiscNav.prestAgenda)),
      body: ListView(
        children: [
          const RoleSwitchSection(sectionTitle: DiscNav.profileSpace),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 56,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  DiscNav.prestAgendaSoonTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  DiscNav.prestAgendaSoonBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
