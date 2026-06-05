import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../shared/utils/phone_number_utils.dart';
import '../providers/profile_city_provider.dart';
import 'profile_info_row.dart';
import 'profile_section_title.dart';
class ProfileMyInfoSection extends ConsumerWidget {
  const ProfileMyInfoSection({
    super.key,
    required this.email,
    required this.phone,
  });

  final String email;
  final String phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityAsync = ref.watch(profileCityLabelProvider);
    final city = cityAsync.when(
      data: (value) => value,
      loading: () => '…',
      error: (_, __) => '—',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(title: DiscProfile.sectionMyInfo),
        DiscoverySurfaceCard(
          child: Column(
            children: [
              ProfileInfoRow(
                icon: Icons.mail_outline_rounded,
                label: DiscProfile.labelEmail,
                value: email.isNotEmpty ? email : '—',
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.1,
                ),
              ),
              ProfileInfoRow(
                icon: Icons.phone_outlined,
                label: DiscProfile.labelPhone,
                value: phone.isNotEmpty
                    ? PhoneNumberUtils.formatForDisplay(phone)
                    : '—',
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.1,
                ),
              ),
              ProfileInfoRow(
                icon: Icons.location_city_outlined,
                label: DiscProfile.labelCity,
                value: city,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

