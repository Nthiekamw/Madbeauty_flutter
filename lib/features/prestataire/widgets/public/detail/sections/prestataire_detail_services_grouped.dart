import 'package:flutter/material.dart';

import '../../../../logic/prestataire_services_grouping.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
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
    final layout = DiscoveryResponsive.of(context);
    final useGrid = layout.useWebSiteLayout && layout.isWide;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          PrestataireDetailServiceGroupHeader(
            title: groups[i].title,
            main: groups[i].main,
            compact: i == 0,
          ),
          if (useGrid)
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 10.0;
                const cols = 2;
                final cardW = (constraints.maxWidth - gap * (cols - 1)) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: 0,
                  children: [
                    for (final service in groups[i].services)
                      SizedBox(
                        width: cardW,
                        child: PrestataireDetailServiceCard(
                          service: service,
                          canBook: canBook,
                          onBook: () => onBook(service.id),
                        ),
                      ),
                  ],
                );
              },
            )
          else
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
