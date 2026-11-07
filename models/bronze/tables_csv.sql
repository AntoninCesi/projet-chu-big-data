CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.hospitalisations` (
  Num_Hospitalisation STRING,
  Id_patient STRING,
  identifiant_organisation STRING,
  Code_diagnostic STRING,
  Suite_diagnostic_consultation STRING,
  Date_Entree STRING,
  Jour_Hospitalisation STRING
);

CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.etablissement_sante` (
  adresse STRING,
  cedex STRING,
  code_commune STRING,
  code_postal STRING,
  commune STRING,
  complement_destinataire STRING,
  complement_point_geographique STRING,
  email STRING,
  enseigne_commerciale_site STRING,
  finess_etablissement_juridique STRING,
  finess_site STRING,
  identifiant_organisation STRING,
  indice_repetition_voie STRING,
  mention_distribution STRING,
  numero_voie STRING,
  pays STRING,
  raison_sociale_site STRING,
  siren_site STRING,
  siret_site STRING,
  telecopie STRING,
  telephone STRING,
  telephone_2 STRING,
  type_voie STRING,
  voie STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.professionnel_sante` (
  identifiant STRING,
  civilite STRING,
  categorie_professionnelle STRING,
  nom STRING,
  prenom STRING,
  commune STRING,
  profession STRING,
  specialite STRING,
  type_identifiant STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.activite_professionnel_sante` (
  identifiant STRING,
  identifiant_organisation STRING,
  mode_exercice STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.esatis_2017` (
  finess STRING,
  rs_finess STRING,
  finess_geo STRING,
  rs_finess_geo STRING,
  region STRING,
  participation STRING,
  Depot STRING,
  nb_rep_score_all_rea_ajust STRING,
  score_all_rea_ajust STRING,
  classement STRING,
  evolution STRING,
  nb_rep_score_accueil_rea_ajust STRING,
  score_accueil_rea_ajust STRING,
  nb_rep_score_PECinf_rea_ajust STRING,
  score_PECinf_rea_ajust STRING,
  nb_rep_score_PECmed_rea_ajust STRING,
  score_PECmed_rea_ajust STRING,
  nb_rep_score_chambre_rea_ajust STRING,
  score_chambre_rea_ajust STRING,
  nb_rep_score_repas_rea_ajust STRING,
  score_repas_rea_ajust STRING,
  nb_rep_score_sortie_rea_ajust STRING,
  score_sortie_rea_ajust STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.esatis_2020` (
  finess STRING,
  rs_finess STRING,
  finess_geo STRING,
  rs_finess_geo STRING,
  region STRING,
  participation STRING,
  Depot STRING,
  nb_rep_score_all_rea_ajust STRING,
  score_all_rea_ajust STRING,
  classement STRING,
  evolution STRING,
  nb_rep_score_accueil_rea_ajust STRING,
  score_accueil_rea_ajust STRING,
  nb_rep_score_PECinf_rea_ajust STRING,
  score_PECinf_rea_ajust STRING,
  nb_rep_score_PECmed_rea_ajust STRING,
  score_PECmed_rea_ajust STRING,
  nb_rep_score_chambre_rea_ajust STRING,
  score_chambre_rea_ajust STRING,
  nb_rep_score_repas_rea_ajust STRING,
  score_repas_rea_ajust STRING,
  nb_rep_score_sortie_rea_ajust STRING,
  score_sortie_rea_ajust STRING,
  taux_reco_brut STRING,
  nb_reco_brut STRING
);

CREATE TABLE `big-data-cloud-healthcare-unit.chu_bronze.deces_insee`
(
  nom STRING,
  prenom STRING,
  sexe STRING,
  date_naissance STRING,
  code_lieu_naissance STRING,
  lieu_naissance STRING,
  pays_naissance STRING,
  date_deces STRING,
  code_lieu_deces STRING,
  numero_acte_deces STRING
)
