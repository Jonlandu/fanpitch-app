// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppL10nPt extends AppL10n {
  AppL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'FanPitch';

  @override
  String get languageName => 'Português';

  @override
  String get languagePickerTitle => 'Escolhe o teu idioma';

  @override
  String get languagePickerSubtitle =>
      'Podes mudá-lo mais tarde nas Definições.';

  @override
  String get languagePickerContinue => 'Continuar';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingCreateAccount => 'Criar a minha conta';

  @override
  String get onboardingAlreadyHaveAccount => 'Já tens conta? Entrar';

  @override
  String get onboardingLiveTitle => 'O jogo ao vivo\nno teu bolso.';

  @override
  String get onboardingLiveSubtitle =>
      'Acompanha cada golo, cartão e momento mágico em tempo real — mesmo quando não estás em frente à TV.';

  @override
  String get onboardingTribeTitle => 'Reage com\na tua tribo.';

  @override
  String get onboardingTribeSubtitle =>
      'Emojis a voar, sondagens-relâmpago, comentários ao rubro. Vive cada jogada com milhares de fãs.';

  @override
  String get onboardingWinTitle => 'Prevê. Marca.\nBrilha.';

  @override
  String get onboardingWinSubtitle =>
      'Faz as tuas apostas antes do apito, ganha pontos, desbloqueia distintivos e sobe na classificação.';

  @override
  String get onboardingReadyTitle => 'Pronto para entrar\nem campo?';

  @override
  String get onboardingReadySubtitle =>
      'Junta-te à comunidade FanPitch em 30 segundos. Sem cartão de crédito — só a tua paixão.';

  @override
  String get loginTitle => 'Entrar';

  @override
  String get loginUsername => 'Nome de utilizador';

  @override
  String get loginPassword => 'Palavra-passe';

  @override
  String get loginSubmit => 'Entrar';

  @override
  String get loginNoAccount => 'Ainda não tens conta? Regista-te';

  @override
  String get loginError => 'Nome de utilizador ou palavra-passe incorretos';

  @override
  String get loginNetworkError =>
      'Não foi possível contactar o servidor. Verifica a tua ligação.';

  @override
  String get registerTitle => 'Criar conta';

  @override
  String get registerDisplayName => 'Nome a apresentar';

  @override
  String get registerUsername => 'Nome de utilizador';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Palavra-passe';

  @override
  String get registerCountry => 'País';

  @override
  String get registerCountryHint => 'Escolhe o teu país';

  @override
  String get registerSubmit => 'Registar';

  @override
  String get registerHaveAccount => 'Já tens conta? Entrar';

  @override
  String registerFailed(String error) {
    return 'Falha no registo: $error';
  }

  @override
  String get matchCompetition => 'Competição';

  @override
  String get matchVenue => 'Local';

  @override
  String matchMinute(int minute) {
    return '$minute\'';
  }

  @override
  String get matchStatsTitle => 'Estatísticas';

  @override
  String get matchStatsScorers => 'Marcadores';

  @override
  String get matchStatsCards => 'Cartões';

  @override
  String get matchStatsPossession => 'Posse de bola';

  @override
  String get matchStatsNoEvents => 'Sem eventos ainda';

  @override
  String get tabForYou => 'Para ti';

  @override
  String get tabLive => 'Live';

  @override
  String get tabMatches => 'Jogos';

  @override
  String get tabMe => 'Eu';

  @override
  String get liveTitle => 'Ao vivo';

  @override
  String get liveNoMatches => 'Sem jogos ao vivo neste momento.';

  @override
  String get liveWatch => 'Ver';

  @override
  String get liveLoading => 'A carregar transmissão…';

  @override
  String get liveStreamError =>
      'Não foi possível carregar o vídeo. Toca para tentar novamente.';

  @override
  String get liveCommentary => 'Comentários ao vivo';

  @override
  String liveMinute(int minute) {
    return '$minute\'';
  }

  @override
  String get feedForYou => 'Para ti';

  @override
  String get feedFollowing => 'A seguir';

  @override
  String get feedEmptyForYou => 'Sem publicações ainda. Sê o primeiro 🔥';

  @override
  String get feedEmptyFollowing => 'Segue fãs para encher este feed.';

  @override
  String get feedRefresh => 'Atualizar';

  @override
  String get feedRetry => 'Tentar de novo';

  @override
  String get feedLoadError => 'Não foi possível carregar o feed.';

  @override
  String feedSeeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver os $count comentários',
      one: 'Ver 1 comentário',
    );
    return '$_temp0';
  }

  @override
  String get createTitle => 'Nova publicação';

  @override
  String get createPost => 'Publicar';

  @override
  String get createHint => 'Qual é a vibe? 🔥';

  @override
  String get createAddImage => 'Adicionar imagem';

  @override
  String get createRemoveImage => 'Remover imagem';

  @override
  String get createAutoExpires => 'As publicações expiram após 7 dias.';

  @override
  String createPostFailed(String error) {
    return 'Falha ao publicar: $error';
  }

  @override
  String get captionStudioTitle => 'Estúdio de Legendas IA';

  @override
  String get captionStudioIntro =>
      'Descreve o momento na tua língua, a IA escreve a legenda perfeita.';

  @override
  String get captionStudioBriefHint =>
      'Ex: fãs congoleses a dançar depois do golo...';

  @override
  String get captionStudioGenerate => 'Gerar legenda';

  @override
  String get captionStudioUse => 'Usar';

  @override
  String get captionStudioRegenerate => 'Regenerar';

  @override
  String captionStudioFailed(String error) {
    return 'Falha na legenda IA: $error';
  }

  @override
  String get profilePoints => 'Pontos';

  @override
  String get profileLevel => 'Nível';

  @override
  String get profileCountry => 'País';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileLanguageChange => 'Mudar idioma';

  @override
  String get profileLogout => 'Terminar sessão';

  @override
  String get matchesTitle => 'Jogos';

  @override
  String get matchStatusUpcoming => 'A vir';

  @override
  String get matchStatusLive => 'Ao vivo';

  @override
  String get matchStatusFinished => 'Terminado';

  @override
  String get hubFeatured => 'Em destaque';

  @override
  String get hubLiveNow => 'Ao vivo';

  @override
  String get hubUpcoming => 'A vir';

  @override
  String get hubFinished => 'Terminados recentemente';

  @override
  String get hubStandings => 'Classificação';

  @override
  String get hubTopScorers => 'Melhores marcadores';

  @override
  String get hubSeeAll => 'Ver tudo';

  @override
  String get hubNoLive => 'Sem jogos ao vivo neste momento.';

  @override
  String get hubNoUpcoming => 'Sem jogos a vir.';

  @override
  String get hubNoFinished => 'Sem jogos terminados.';

  @override
  String get hubPossession => 'Posse';

  @override
  String hubGoals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count golos',
      one: '1 golo',
    );
    return '$_temp0';
  }

  @override
  String get standingsP => 'J';

  @override
  String get standingsW => 'V';

  @override
  String get standingsD => 'E';

  @override
  String get standingsL => 'D';

  @override
  String get standingsGd => '+/−';

  @override
  String get standingsPts => 'Pts';

  @override
  String get standingsTeam => 'Equipa';

  @override
  String get leaderboardTitle => 'Classificação';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonError => 'Erro';

  @override
  String get commonLoading => 'A carregar…';
}
