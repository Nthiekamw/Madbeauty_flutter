import 'package:flutter/material.dart';

import '../../../../logic/prestataire_services_grouping.dart';
import 'prestataire_detail_service_card.dart';
import 'prestataire_detail_service_group_header.dart';

class PrestataireDetailServicesGrouped extends StatelessWidget {
  const PrestataireDetailServicesGrouped({
    super.key,
    required this.groups,
    required this.canBook,
    required this.onBook,
  });

  final List<PrestataireServiceMainGroup> groups;
  final bool canBook;
  final void Function(String serviceId) onBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          PrestataireDetailServiceGroupHeader(
            title: groups[i].title,
            main: groups[i].main,
            compact: i == 0,
          ),
          for (final service in groups[i].services)
            PrestataireDetailServiceCard(
              service: service,
              canBook: canBook,
              onBook: () => onBook(service.id),
            ),
        ],
      ],
    );
  }
}
