import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_providers.dart';
import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';

export '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart'
    show
        PrestataireProfileFormData,
        PrestataireProfileSavePayload,
        PrestataireServiceFormData;
export '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_providers.dart'
    show prestataireProfileFormServiceProvider;

final prestataireProfileFormProvider =
    FutureProvider.autoDispose<PrestataireProfileFormData>((ref) async {
      final service = ref.watch(prestataireProfileFormServiceProvider);
      if (service == null) return PrestataireProfileFormData.empty;
      return service.fetch();
    });
