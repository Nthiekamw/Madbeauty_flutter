import 'package:flutter/material.dart';

import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';

/// Contrôleurs et erreurs d'une ligne de service dans le formulaire prestataire.
class PrestataireServiceFieldSet {
  PrestataireServiceFieldSet({
    this.id,
    String nom = '',
    String description = '',
    this.categorieId,
    String prix = '0',
    String duree = '60',
  }) : nomController = TextEditingController(text: nom),
       descriptionController = TextEditingController(text: description),
       prixController = TextEditingController(text: prix),
       dureeController = TextEditingController(text: duree);

  factory PrestataireServiceFieldSet.fromData(PrestataireServiceFormData data) {
    return PrestataireServiceFieldSet(
      id: data.id,
      nom: data.nom,
      description: data.description,
      categorieId: data.categorieId,
      prix: data.prix == 0 ? '0' : data.prix.toStringAsFixed(2),
      duree: data.dureeMinutes.toString(),
    );
  }

  final String? id;
  final TextEditingController nomController;
  final TextEditingController descriptionController;
  final TextEditingController prixController;
  final TextEditingController dureeController;
  String? categorieId;

  String? nomError;
  String? categorieError;
  String? prixError;
  String? dureeError;

  void dispose() {
    nomController.dispose();
    descriptionController.dispose();
    prixController.dispose();
    dureeController.dispose();
  }
}
