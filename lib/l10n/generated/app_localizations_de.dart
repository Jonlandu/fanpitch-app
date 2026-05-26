// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppL10nDe extends AppL10n {
  AppL10nDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'FanPitch';

  @override
  String get languageName => 'Deutsch';

  @override
  String get languagePickerTitle => 'Wähle deine Sprache';

  @override
  String get languagePickerSubtitle =>
      'Du kannst sie später in den Einstellungen ändern.';

  @override
  String get languagePickerContinue => 'Weiter';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingContinue => 'Weiter';

  @override
  String get onboardingCreateAccount => 'Konto erstellen';

  @override
  String get onboardingAlreadyHaveAccount => 'Schon dabei? Anmelden';

  @override
  String get onboardingLiveTitle => 'Das Live-Spiel\nin deiner Tasche.';

  @override
  String get onboardingLiveSubtitle =>
      'Verfolge jedes Tor, jede Karte und jeden magischen Moment in Echtzeit — auch wenn du nicht vor dem Fernseher bist.';

  @override
  String get onboardingTribeTitle => 'Reagiere mit\ndeiner Crew.';

  @override
  String get onboardingTribeSubtitle =>
      'Fliegende Emojis, Blitzumfragen, hitzige Kommentare. Erlebe jeden Spielzug mit Tausenden Fans.';

  @override
  String get onboardingWinTitle => 'Tippe. Treffe.\nStrahle.';

  @override
  String get onboardingWinSubtitle =>
      'Setze deine Tipps vor dem Anpfiff, sammle Punkte, schalte Abzeichen frei und klettere in der Rangliste.';

  @override
  String get onboardingReadyTitle => 'Bereit, das Feld\nzu betreten?';

  @override
  String get onboardingReadySubtitle =>
      'Tritt der FanPitch-Community in 30 Sekunden bei. Keine Kreditkarte — nur deine Leidenschaft.';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginUsername => 'Benutzername';

  @override
  String get loginPassword => 'Passwort';

  @override
  String get loginSubmit => 'Anmelden';

  @override
  String get loginNoAccount => 'Noch kein Konto? Registrieren';

  @override
  String get loginError => 'Ungültige Anmeldedaten';

  @override
  String get registerTitle => 'Konto erstellen';

  @override
  String get registerDisplayName => 'Anzeigename';

  @override
  String get registerUsername => 'Benutzername';

  @override
  String get registerEmail => 'E-Mail';

  @override
  String get registerPassword => 'Passwort';

  @override
  String get registerCountry => 'Land';

  @override
  String get registerCountryHint => 'Wähle dein Land';

  @override
  String get registerSubmit => 'Registrieren';

  @override
  String get registerHaveAccount => 'Schon dabei? Anmelden';

  @override
  String registerFailed(String error) {
    return 'Registrierung fehlgeschlagen: $error';
  }

  @override
  String get matchCompetition => 'Wettbewerb';

  @override
  String get matchVenue => 'Stadion';

  @override
  String matchMinute(int minute) {
    return '$minute\'';
  }

  @override
  String get matchStatsTitle => 'Statistik';

  @override
  String get matchStatsScorers => 'Torschützen';

  @override
  String get matchStatsCards => 'Karten';

  @override
  String get matchStatsPossession => 'Ballbesitz';

  @override
  String get matchStatsNoEvents => 'Noch keine Ereignisse';

  @override
  String get tabForYou => 'Für dich';

  @override
  String get tabMatches => 'Spiele';

  @override
  String get tabMe => 'Ich';

  @override
  String get feedForYou => 'Für dich';

  @override
  String get feedFollowing => 'Folge ich';

  @override
  String get feedEmptyForYou => 'Noch keine Beiträge. Sei der Erste 🔥';

  @override
  String get feedEmptyFollowing =>
      'Folge anderen Fans, um diesen Feed zu füllen.';

  @override
  String get feedRefresh => 'Aktualisieren';

  @override
  String get feedRetry => 'Erneut versuchen';

  @override
  String get feedLoadError => 'Feed konnte nicht geladen werden.';

  @override
  String feedSeeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Kommentare ansehen',
      one: '1 Kommentar ansehen',
    );
    return '$_temp0';
  }

  @override
  String get createTitle => 'Neuer Beitrag';

  @override
  String get createPost => 'Posten';

  @override
  String get createHint => 'Wie ist die Stimmung? 🔥';

  @override
  String get createAddImage => 'Bild hinzufügen';

  @override
  String get createRemoveImage => 'Bild entfernen';

  @override
  String get createAutoExpires =>
      'Beiträge verfallen nach 7 Tagen automatisch.';

  @override
  String createPostFailed(String error) {
    return 'Posten fehlgeschlagen: $error';
  }

  @override
  String get captionStudioTitle => 'KI-Beschriftungsstudio';

  @override
  String get captionStudioIntro =>
      'Beschreibe den Moment in deiner Sprache — die KI schreibt die perfekte Beschriftung.';

  @override
  String get captionStudioBriefHint =>
      'z. B. Kongolesische Fans tanzen nach dem Tor...';

  @override
  String get captionStudioGenerate => 'Beschriftung erzeugen';

  @override
  String get captionStudioUse => 'Übernehmen';

  @override
  String get captionStudioRegenerate => 'Neu erzeugen';

  @override
  String captionStudioFailed(String error) {
    return 'KI-Beschriftung fehlgeschlagen: $error';
  }

  @override
  String get profilePoints => 'Punkte';

  @override
  String get profileLevel => 'Stufe';

  @override
  String get profileCountry => 'Land';

  @override
  String get profileLanguage => 'Sprache';

  @override
  String get profileLanguageChange => 'Sprache ändern';

  @override
  String get profileLogout => 'Abmelden';

  @override
  String get matchesTitle => 'Spiele';

  @override
  String get matchStatusUpcoming => 'Bald';

  @override
  String get matchStatusLive => 'Live';

  @override
  String get matchStatusFinished => 'Beendet';

  @override
  String get leaderboardTitle => 'Rangliste';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonError => 'Fehler';

  @override
  String get commonLoading => 'Lädt…';
}
