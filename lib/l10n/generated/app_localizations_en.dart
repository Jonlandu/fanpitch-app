// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FanPitch';

  @override
  String get languageName => 'English';

  @override
  String get languagePickerTitle => 'Choose your language';

  @override
  String get languagePickerSubtitle => 'You can change it later in Settings.';

  @override
  String get languagePickerContinue => 'Continue';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingCreateAccount => 'Create my account';

  @override
  String get onboardingAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get onboardingLiveTitle => 'The live match\nin your pocket.';

  @override
  String get onboardingLiveSubtitle =>
      'Follow every goal, card and magic moment in real time — even when you\'re away from the TV.';

  @override
  String get onboardingTribeTitle => 'React with\nyour tribe.';

  @override
  String get onboardingTribeSubtitle =>
      'Flying emojis, lightning polls, comments that heat up. Live every play with thousands of fans.';

  @override
  String get onboardingWinTitle => 'Predict. Score.\nShine.';

  @override
  String get onboardingWinSubtitle =>
      'Place your picks before kickoff, earn points, unlock badges and climb the leaderboard.';

  @override
  String get onboardingReadyTitle => 'Ready to step\nonto the pitch?';

  @override
  String get onboardingReadySubtitle =>
      'Join the FanPitch community in 30 seconds. No credit card — just your passion.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginNoAccount => 'No account yet? Sign up';

  @override
  String get loginError => 'Username or password is incorrect';

  @override
  String get loginNetworkError =>
      'Cannot reach the server. Check your connection.';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerDisplayName => 'Display name';

  @override
  String get registerUsername => 'Username';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerCountry => 'Country';

  @override
  String get registerCountryHint => 'Pick your country';

  @override
  String get registerSubmit => 'Sign up';

  @override
  String get registerHaveAccount => 'Already have an account? Sign in';

  @override
  String registerFailed(String error) {
    return 'Sign up failed: $error';
  }

  @override
  String get matchCompetition => 'Competition';

  @override
  String get matchVenue => 'Venue';

  @override
  String matchMinute(int minute) {
    return '$minute\'';
  }

  @override
  String get matchStatsTitle => 'Stats';

  @override
  String get matchStatsScorers => 'Scorers';

  @override
  String get matchStatsCards => 'Cards';

  @override
  String get matchStatsPossession => 'Possession';

  @override
  String get matchStatsNoEvents => 'No events yet';

  @override
  String get tabForYou => 'For you';

  @override
  String get tabMatches => 'Matches';

  @override
  String get tabMe => 'Me';

  @override
  String get feedForYou => 'For you';

  @override
  String get feedFollowing => 'Following';

  @override
  String get feedEmptyForYou => 'No posts yet. Be the first 🔥';

  @override
  String get feedEmptyFollowing => 'Follow some fans to populate this feed.';

  @override
  String get feedRefresh => 'Refresh';

  @override
  String get feedRetry => 'Retry';

  @override
  String get feedLoadError => 'Couldn\'t load the feed.';

  @override
  String feedSeeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'See all $count comments',
      one: 'See 1 comment',
    );
    return '$_temp0';
  }

  @override
  String get createTitle => 'New status';

  @override
  String get createPost => 'Post';

  @override
  String get createHint => 'What\'s the vibe? 🔥';

  @override
  String get createAddImage => 'Add image';

  @override
  String get createRemoveImage => 'Remove image';

  @override
  String get createAutoExpires => 'Posts auto-expire after 7 days.';

  @override
  String createPostFailed(String error) {
    return 'Post failed: $error';
  }

  @override
  String get captionStudioTitle => 'AI Caption Studio';

  @override
  String get captionStudioIntro =>
      'Describe the moment in your language, the AI writes the perfect caption.';

  @override
  String get captionStudioBriefHint =>
      'e.g. Congolese fans dancing after the goal...';

  @override
  String get captionStudioGenerate => 'Generate caption';

  @override
  String get captionStudioUse => 'Use it';

  @override
  String get captionStudioRegenerate => 'Regenerate';

  @override
  String captionStudioFailed(String error) {
    return 'AI caption failed: $error';
  }

  @override
  String get profilePoints => 'Points';

  @override
  String get profileLevel => 'Level';

  @override
  String get profileCountry => 'Country';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageChange => 'Change language';

  @override
  String get profileLogout => 'Log out';

  @override
  String get matchesTitle => 'Matches';

  @override
  String get matchStatusUpcoming => 'Upcoming';

  @override
  String get matchStatusLive => 'Live';

  @override
  String get matchStatusFinished => 'Finished';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonError => 'Error';

  @override
  String get commonLoading => 'Loading…';
}
