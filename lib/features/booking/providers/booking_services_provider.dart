import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../prestataire/providers/prestataire_services_provider.dart';

final bookingActiveServicesProvider = FutureProvider.autoDispose
    .family<List<ServiceBeaute>, String>((ref, prestataireId) async {
      final services = await ref.watch(servicesProvider(prestataireId).future);
      return services.where((service) => service.isActif).toList();
    });
