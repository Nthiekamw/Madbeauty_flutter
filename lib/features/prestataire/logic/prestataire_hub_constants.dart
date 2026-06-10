import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../widgets/profile/hub/prestataire_hub_layout.dart';

abstract final class PrestataireHubConstants {
  PrestataireHubConstants._();

  static const galleryMaxPhotos = 10;
  static const wizardStepCount = 7;
  static const optionalFromStep = 4;

  static const defaultAvatarUrls = <String>[
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty1',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty2',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty3',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty4',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty5',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty6',
  ];
}

const List<PrestataireHubStepMeta> kPrestataireHubSteps = [
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepBasics,
    icon: Icons.storefront_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepLocation,
    icon: Icons.location_on_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepServices,
    icon: Icons.content_cut_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepHoraires,
    icon: Icons.schedule_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepGallery,
    icon: Icons.photo_library_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepComfort,
    icon: Icons.favorite_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepSubscription,
    icon: Icons.card_membership_outlined,
  ),
];
