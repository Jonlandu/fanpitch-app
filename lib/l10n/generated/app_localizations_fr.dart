// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppL10nFr extends AppL10n {
  AppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'FanPitch';

  @override
  String get languageName => 'Français';

  @override
  String get languagePickerTitle => 'Choisis ta langue';

  @override
  String get languagePickerSubtitle =>
      'Tu pourras la changer plus tard dans les paramètres.';

  @override
  String get languagePickerContinue => 'Continuer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingCreateAccount => 'Créer mon compte';

  @override
  String get onboardingAlreadyHaveAccount => 'Déjà inscrit ? Connecte-toi';

  @override
  String get onboardingLiveTitle => 'Le match en direct\ndans ta poche.';

  @override
  String get onboardingLiveSubtitle =>
      'Suis chaque but, carton et moment magique en temps réel — même quand tu n\'es pas devant la TV.';

  @override
  String get onboardingTribeTitle => 'Réagis avec\nta tribu.';

  @override
  String get onboardingTribeSubtitle =>
      'Émojis qui fusent, sondages éclair, commentaires qui chauffent. Vis chaque action avec des milliers de fans.';

  @override
  String get onboardingWinTitle => 'Prédis. Score.\nBrille.';

  @override
  String get onboardingWinSubtitle =>
      'Place tes paris avant le coup d\'envoi, gagne des points, débloque des badges et grimpe au classement.';

  @override
  String get onboardingReadyTitle => 'Prêt à entrer\nsur le terrain ?';

  @override
  String get onboardingReadySubtitle =>
      'Rejoins la communauté FanPitch en 30 secondes. Aucune carte de crédit, juste ta passion.';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginUsername => 'Nom d\'utilisateur';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginNoAccount => 'Pas encore de compte ? Inscris-toi';

  @override
  String get loginError => 'Nom d\'utilisateur ou mot de passe incorrect';

  @override
  String get loginNetworkError =>
      'Impossible de joindre le serveur. Vérifie ta connexion.';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerDisplayName => 'Nom à afficher';

  @override
  String get registerUsername => 'Nom d\'utilisateur';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Mot de passe';

  @override
  String get registerCountry => 'Pays';

  @override
  String get registerCountryHint => 'Choisis ton pays';

  @override
  String get registerSubmit => 'S\'inscrire';

  @override
  String get registerHaveAccount => 'Déjà inscrit ? Connecte-toi';

  @override
  String registerFailed(String error) {
    return 'Inscription échouée : $error';
  }

  @override
  String get matchCompetition => 'Compétition';

  @override
  String get matchVenue => 'Lieu';

  @override
  String matchMinute(int minute) {
    return '$minute\'';
  }

  @override
  String get matchStatsTitle => 'Statistiques';

  @override
  String get matchStatsScorers => 'Buteurs';

  @override
  String get matchStatsCards => 'Cartons';

  @override
  String get matchStatsPossession => 'Possession';

  @override
  String get matchStatsNoEvents => 'Aucun événement pour l\'instant';

  @override
  String get tabForYou => 'Pour toi';

  @override
  String get tabMatches => 'Matchs';

  @override
  String get tabMe => 'Moi';

  @override
  String get feedForYou => 'Pour toi';

  @override
  String get feedFollowing => 'Abonnements';

  @override
  String get feedEmptyForYou =>
      'Aucune publication pour l\'instant. Sois le premier 🔥';

  @override
  String get feedEmptyFollowing => 'Suis des fans pour remplir ce fil.';

  @override
  String get feedRefresh => 'Actualiser';

  @override
  String get feedRetry => 'Réessayer';

  @override
  String get feedLoadError => 'Impossible de charger le fil.';

  @override
  String feedSeeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voir les $count commentaires',
      one: 'Voir 1 commentaire',
    );
    return '$_temp0';
  }

  @override
  String get createTitle => 'Nouvelle publication';

  @override
  String get createPost => 'Publier';

  @override
  String get createHint => 'Qu\'est-ce qui se passe ? 🔥';

  @override
  String get createAddImage => 'Ajouter une image';

  @override
  String get createRemoveImage => 'Retirer l\'image';

  @override
  String get createAutoExpires =>
      'Les publications expirent au bout de 7 jours.';

  @override
  String createPostFailed(String error) {
    return 'Échec de la publication : $error';
  }

  @override
  String get captionStudioTitle => 'Studio de légendes IA';

  @override
  String get captionStudioIntro =>
      'Décris le moment dans ta langue, l\'IA écrit la légende parfaite.';

  @override
  String get captionStudioBriefHint =>
      'Ex: les fans congolais qui dansent après le but...';

  @override
  String get captionStudioGenerate => 'Générer la légende';

  @override
  String get captionStudioUse => 'Utiliser';

  @override
  String get captionStudioRegenerate => 'Régénérer';

  @override
  String captionStudioFailed(String error) {
    return 'Échec de la légende IA : $error';
  }

  @override
  String get profilePoints => 'Points';

  @override
  String get profileLevel => 'Niveau';

  @override
  String get profileCountry => 'Pays';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLanguageChange => 'Changer la langue';

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get matchesTitle => 'Matchs';

  @override
  String get matchStatusUpcoming => 'À venir';

  @override
  String get matchStatusLive => 'En direct';

  @override
  String get matchStatusFinished => 'Terminé';

  @override
  String get hubFeatured => 'À l\'affiche';

  @override
  String get hubLiveNow => 'En direct';

  @override
  String get hubUpcoming => 'À venir';

  @override
  String get hubFinished => 'Récemment terminés';

  @override
  String get hubStandings => 'Classement';

  @override
  String get hubTopScorers => 'Meilleurs buteurs';

  @override
  String get hubSeeAll => 'Voir tout';

  @override
  String get hubNoLive => 'Aucun match en direct pour le moment.';

  @override
  String get hubNoUpcoming => 'Aucun match à venir.';

  @override
  String get hubNoFinished => 'Aucun match terminé.';

  @override
  String get hubPossession => 'Possession';

  @override
  String hubGoals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count buts',
      one: '1 but',
    );
    return '$_temp0';
  }

  @override
  String get standingsP => 'MJ';

  @override
  String get standingsW => 'G';

  @override
  String get standingsD => 'N';

  @override
  String get standingsL => 'P';

  @override
  String get standingsGd => '+/−';

  @override
  String get standingsPts => 'Pts';

  @override
  String get standingsTeam => 'Équipe';

  @override
  String get leaderboardTitle => 'Classement';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonLoading => 'Chargement…';
}
