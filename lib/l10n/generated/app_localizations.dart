import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'FanPitch'**
  String get appName;

  /// No description provided for @languageName.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageName;

  /// No description provided for @languagePickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ta langue'**
  String get languagePickerTitle;

  /// No description provided for @languagePickerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tu pourras la changer plus tard dans les paramètres.'**
  String get languagePickerSubtitle;

  /// No description provided for @languagePickerContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get languagePickerContinue;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @onboardingContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get onboardingContinue;

  /// No description provided for @onboardingCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get onboardingCreateAccount;

  /// No description provided for @onboardingAlreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inscrit ? Connecte-toi'**
  String get onboardingAlreadyHaveAccount;

  /// No description provided for @onboardingLiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Le match en direct\ndans ta poche.'**
  String get onboardingLiveTitle;

  /// No description provided for @onboardingLiveSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suis chaque but, carton et moment magique en temps réel — même quand tu n\'es pas devant la TV.'**
  String get onboardingLiveSubtitle;

  /// No description provided for @onboardingTribeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réagis avec\nta tribu.'**
  String get onboardingTribeTitle;

  /// No description provided for @onboardingTribeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Émojis qui fusent, sondages éclair, commentaires qui chauffent. Vis chaque action avec des milliers de fans.'**
  String get onboardingTribeSubtitle;

  /// No description provided for @onboardingWinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prédis. Score.\nBrille.'**
  String get onboardingWinTitle;

  /// No description provided for @onboardingWinSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Place tes paris avant le coup d\'envoi, gagne des points, débloque des badges et grimpe au classement.'**
  String get onboardingWinSubtitle;

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prêt à entrer\nsur le terrain ?'**
  String get onboardingReadyTitle;

  /// No description provided for @onboardingReadySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins la communauté FanPitch en 30 secondes. Aucune carte de crédit, juste ta passion.'**
  String get onboardingReadySubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginSubmit;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? Inscris-toi'**
  String get loginNoAccount;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur ou mot de passe incorrect'**
  String get loginError;

  /// No description provided for @loginNetworkError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifie ta connexion.'**
  String get loginNetworkError;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @registerDisplayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom à afficher'**
  String get registerDisplayName;

  /// No description provided for @registerUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get registerUsername;

  /// No description provided for @registerEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerPassword;

  /// No description provided for @registerCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get registerCountry;

  /// No description provided for @registerCountryHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton pays'**
  String get registerCountryHint;

  /// No description provided for @registerSubmit.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get registerSubmit;

  /// No description provided for @registerHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inscrit ? Connecte-toi'**
  String get registerHaveAccount;

  /// No description provided for @registerFailed.
  ///
  /// In fr, this message translates to:
  /// **'Inscription échouée : {error}'**
  String registerFailed(String error);

  /// No description provided for @matchCompetition.
  ///
  /// In fr, this message translates to:
  /// **'Compétition'**
  String get matchCompetition;

  /// No description provided for @matchVenue.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get matchVenue;

  /// No description provided for @matchMinute.
  ///
  /// In fr, this message translates to:
  /// **'{minute}\''**
  String matchMinute(int minute);

  /// No description provided for @matchStatsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get matchStatsTitle;

  /// No description provided for @matchStatsScorers.
  ///
  /// In fr, this message translates to:
  /// **'Buteurs'**
  String get matchStatsScorers;

  /// No description provided for @matchStatsCards.
  ///
  /// In fr, this message translates to:
  /// **'Cartons'**
  String get matchStatsCards;

  /// No description provided for @matchStatsPossession.
  ///
  /// In fr, this message translates to:
  /// **'Possession'**
  String get matchStatsPossession;

  /// No description provided for @matchStatsNoEvents.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement pour l\'instant'**
  String get matchStatsNoEvents;

  /// No description provided for @tabForYou.
  ///
  /// In fr, this message translates to:
  /// **'Pour toi'**
  String get tabForYou;

  /// No description provided for @tabLive.
  ///
  /// In fr, this message translates to:
  /// **'Live'**
  String get tabLive;

  /// No description provided for @tabMatches.
  ///
  /// In fr, this message translates to:
  /// **'Matchs'**
  String get tabMatches;

  /// No description provided for @tabMe.
  ///
  /// In fr, this message translates to:
  /// **'Moi'**
  String get tabMe;

  /// No description provided for @liveTitle.
  ///
  /// In fr, this message translates to:
  /// **'En direct'**
  String get liveTitle;

  /// No description provided for @liveNoMatches.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match en direct pour le moment.'**
  String get liveNoMatches;

  /// No description provided for @liveWatch.
  ///
  /// In fr, this message translates to:
  /// **'Regarder'**
  String get liveWatch;

  /// No description provided for @liveLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement du flux…'**
  String get liveLoading;

  /// No description provided for @liveStreamError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la vidéo. Réessaie.'**
  String get liveStreamError;

  /// No description provided for @liveCommentary.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires en direct'**
  String get liveCommentary;

  /// No description provided for @liveMinute.
  ///
  /// In fr, this message translates to:
  /// **'{minute}\''**
  String liveMinute(int minute);

  /// No description provided for @feedForYou.
  ///
  /// In fr, this message translates to:
  /// **'Pour toi'**
  String get feedForYou;

  /// No description provided for @feedFollowing.
  ///
  /// In fr, this message translates to:
  /// **'Abonnements'**
  String get feedFollowing;

  /// No description provided for @feedEmptyForYou.
  ///
  /// In fr, this message translates to:
  /// **'Aucune publication pour l\'instant. Sois le premier 🔥'**
  String get feedEmptyForYou;

  /// No description provided for @feedEmptyFollowing.
  ///
  /// In fr, this message translates to:
  /// **'Suis des fans pour remplir ce fil.'**
  String get feedEmptyFollowing;

  /// No description provided for @feedRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get feedRefresh;

  /// No description provided for @feedRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get feedRetry;

  /// No description provided for @feedLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le fil.'**
  String get feedLoadError;

  /// No description provided for @feedSeeComments.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Voir 1 commentaire} other{Voir les {count} commentaires}}'**
  String feedSeeComments(int count);

  /// No description provided for @createTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle publication'**
  String get createTitle;

  /// No description provided for @createPost.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get createPost;

  /// No description provided for @createHint.
  ///
  /// In fr, this message translates to:
  /// **'Qu\'est-ce qui se passe ? 🔥'**
  String get createHint;

  /// No description provided for @createAddImage.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une image'**
  String get createAddImage;

  /// No description provided for @createRemoveImage.
  ///
  /// In fr, this message translates to:
  /// **'Retirer l\'image'**
  String get createRemoveImage;

  /// No description provided for @createAutoExpires.
  ///
  /// In fr, this message translates to:
  /// **'Les publications expirent au bout de 7 jours.'**
  String get createAutoExpires;

  /// No description provided for @createPostFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la publication : {error}'**
  String createPostFailed(String error);

  /// No description provided for @captionStudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Studio de légendes IA'**
  String get captionStudioTitle;

  /// No description provided for @captionStudioIntro.
  ///
  /// In fr, this message translates to:
  /// **'Décris le moment dans ta langue, l\'IA écrit la légende parfaite.'**
  String get captionStudioIntro;

  /// No description provided for @captionStudioBriefHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: les fans congolais qui dansent après le but...'**
  String get captionStudioBriefHint;

  /// No description provided for @captionStudioGenerate.
  ///
  /// In fr, this message translates to:
  /// **'Générer la légende'**
  String get captionStudioGenerate;

  /// No description provided for @captionStudioUse.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser'**
  String get captionStudioUse;

  /// No description provided for @captionStudioRegenerate.
  ///
  /// In fr, this message translates to:
  /// **'Régénérer'**
  String get captionStudioRegenerate;

  /// No description provided for @captionStudioFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la légende IA : {error}'**
  String captionStudioFailed(String error);

  /// No description provided for @profilePoints.
  ///
  /// In fr, this message translates to:
  /// **'Points'**
  String get profilePoints;

  /// No description provided for @profileLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get profileLevel;

  /// No description provided for @profileCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get profileCountry;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// No description provided for @profileLanguageChange.
  ///
  /// In fr, this message translates to:
  /// **'Changer la langue'**
  String get profileLanguageChange;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @matchesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Matchs'**
  String get matchesTitle;

  /// No description provided for @matchStatusUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get matchStatusUpcoming;

  /// No description provided for @matchStatusLive.
  ///
  /// In fr, this message translates to:
  /// **'En direct'**
  String get matchStatusLive;

  /// No description provided for @matchStatusFinished.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get matchStatusFinished;

  /// No description provided for @hubFeatured.
  ///
  /// In fr, this message translates to:
  /// **'À l\'affiche'**
  String get hubFeatured;

  /// No description provided for @hubLiveNow.
  ///
  /// In fr, this message translates to:
  /// **'En direct'**
  String get hubLiveNow;

  /// No description provided for @hubUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get hubUpcoming;

  /// No description provided for @hubFinished.
  ///
  /// In fr, this message translates to:
  /// **'Récemment terminés'**
  String get hubFinished;

  /// No description provided for @hubStandings.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get hubStandings;

  /// No description provided for @hubTopScorers.
  ///
  /// In fr, this message translates to:
  /// **'Meilleurs buteurs'**
  String get hubTopScorers;

  /// No description provided for @hubSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get hubSeeAll;

  /// No description provided for @hubNoLive.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match en direct pour le moment.'**
  String get hubNoLive;

  /// No description provided for @hubNoUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match à venir.'**
  String get hubNoUpcoming;

  /// No description provided for @hubNoFinished.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match terminé.'**
  String get hubNoFinished;

  /// No description provided for @hubPossession.
  ///
  /// In fr, this message translates to:
  /// **'Possession'**
  String get hubPossession;

  /// No description provided for @hubGoals.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 but} other{{count} buts}}'**
  String hubGoals(int count);

  /// No description provided for @standingsP.
  ///
  /// In fr, this message translates to:
  /// **'MJ'**
  String get standingsP;

  /// No description provided for @standingsW.
  ///
  /// In fr, this message translates to:
  /// **'G'**
  String get standingsW;

  /// No description provided for @standingsD.
  ///
  /// In fr, this message translates to:
  /// **'N'**
  String get standingsD;

  /// No description provided for @standingsL.
  ///
  /// In fr, this message translates to:
  /// **'P'**
  String get standingsL;

  /// No description provided for @standingsGd.
  ///
  /// In fr, this message translates to:
  /// **'+/−'**
  String get standingsGd;

  /// No description provided for @standingsPts.
  ///
  /// In fr, this message translates to:
  /// **'Pts'**
  String get standingsPts;

  /// No description provided for @standingsTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get standingsTeam;

  /// No description provided for @leaderboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get leaderboardTitle;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get commonError;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get commonLoading;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppL10nDe();
    case 'en':
      return AppL10nEn();
    case 'es':
      return AppL10nEs();
    case 'fr':
      return AppL10nFr();
    case 'pt':
      return AppL10nPt();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
