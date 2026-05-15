import 'package:flutter/material.dart';

import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';

/// Contrôleurs et erreurs d'une ligne de service dans le formulaire prestataire.
class PrestataireServiceFieldSet {
  PrestataireServiceFieldSet({
    this.id,
    String nom = '',
    String prix = '',
    String duree = '',
  }) : nomController = TextEditingController(text: nom),
       prixController = TextEditingController(text: prix),
       dureeController = TextEditingController(text: duree);

  factory PrestataireServiceFieldSet.fromData(PrestataireServiceFormData data) {
    return PrestataireServiceFieldSet(
      id: data.id,
      nom: data.nom,
      prix: data.prix == 0 ? '' : data.prix.toStringAsFixed(2),
      duree: data.dureeMinutes == 0 ? '' : data.dureeMinutes.toString(),
    );
  }

  final String? id;
  final TextEditingController nomController;
  final TextEditingController prixController;
  final TextEditingController dureeController;

  String? nomError;
  String? prixError;
  String? dureeError;

  void dispose() {
    nomController.dispose();
    prixController.dispose();
    dureeController.dispose();
  }
}
