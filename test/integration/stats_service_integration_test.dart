import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_analytics_period.dart';
import 'package:madbeauty/services/supabase/prestataire/catalog/prestataire_service.dart';
import 'package:madbeauty/services/supabase/profile/profile_service.dart';
import 'package:madbeauty/services/supabase/stats/stats_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _runIntegration = bool.fromEnvironment(
  'MADBEAUTY_RUN_SUPABASE_INTEGRATION',
);
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _testEmail = String.fromEnvironment('SUPABASE_TEST_EMAIL');
const _testPassword = String.fromEnvironment('SUPABASE_TEST_PASSWORD');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'StatsService.getStats — données réelles prestataire connecté',
    () async {
      final client = SupabaseClient(_supabaseUrl, _supabaseAnonKey);
      final auth = await client.auth.signInWithPassword(
        email: _testEmail,
        password: _testPassword,
      );
      final user = auth.user;
      expect(user, isNotNull);

      final profileService = ProfileService(client);
      final prestataireService = PrestataireService(
        client,
        profileService: profileService,
      );
      final statsService = StatsService(client);

      final presta = await prestataireService.getByUserId(user!.id);
      if (presta == null) {
        // Compte client uniquement : test ignoré.
        return;
      }

      for (final period in PrestataireAnalyticsPeriod.values) {
        final stats = await statsService.getStats(
          prestataireId: presta.id,
          period: period,
        );

        expect(stats.prestataireId, presta.id);
        expect(stats.periodDays, period.days);
        expect(stats.caPeriodCents, greaterThanOrEqualTo(0));
        expect(stats.bookingsTotal, greaterThanOrEqualTo(0));
        expect(stats.weekdayHeatmap, hasLength(7));
        expect(stats.occupancyPercent, inInclusiveRange(0, 100));
      }

      final calendar = await statsService.getCalendarMonthStats(presta.id);
      expect(calendar, isNotNull);
      expect(calendar!.caPeriodCents, greaterThanOrEqualTo(0));
    },
    skip: !_runIntegration,
  );
}
