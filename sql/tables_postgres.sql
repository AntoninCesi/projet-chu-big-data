CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.consultation` (
  Num_consultation INT64,
  Id_mut INT64,
  Id_patient INT64,
  Id_prof_sante STRING,
  Code_diag STRING,
  Motif STRING,
  Date DATE,
  Heure_debut TIME,
  Heure_fin TIME
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.diagnostic` (
  Code_diag STRING,
  Diagnostic STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.medicaments` (
  Code_CIS STRING,
  Denomination STRING,
  Forme_pharmaceutique STRING,
  Voies_d_administration STRING,
  Statut_administratif STRING,
  Type_de_procedure STRING,
  Etat_de_commercialisation STRING,
  Date_AMM STRING,
  StatutBdm STRING,
  Num_autorisation_europeenne STRING,
  Titulaire STRING,
  Surveillance_renforcee STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.patient` (
  Id_patient INT64,
  Nom STRING,
  Prenom STRING,
  Sexe STRING,
  Adresse STRING,
  Ville STRING,
  Code_postal STRING,
  Pays STRING,
  EMail STRING,
  Tel STRING,
  Date STRING,
  Age INT64,
  Num_Secu STRING,
  Groupe_sanguin STRING,
  Poid STRING,
  Taille STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.prescription` (
  Num_consultation INT64,
  Code_CIS STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.professionnel_de_sante` (
  Identifiant STRING,
  Civilite STRING,
  Categorie_professionnelle STRING,
  Nom STRING,
  Prenom STRING,
  Profession STRING,
  Type_identifiant STRING,
  Code_specialite STRING
);


CREATE TABLE IF NOT EXISTS `big-data-cloud-healthcare-unit.chu_bronze.specialites` (
  Code_specialite STRING,
  Fonction STRING,
  Specialite STRING
);
