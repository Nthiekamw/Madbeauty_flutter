import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prestataire_analytics_period.dart';

class _AnalyticsPeriodNotifier extends Notifier<PrestataireAnalyticsPeriod> {
  @override
  PrestataireAnalyticsPeriod build() => PrestataireAnalyticsPeriod.days30;

  void setPeriod(PrestataireAnalyticsPeriod period) => state = period;
}

final prestataireAnalyticsPeriodProvider =
    NotifierProvider<_AnalyticsPeriodNotifier, PrestataireAnalyticsPeriod>(
  _AnalyticsPeriodNotifier.new,
);

