// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'FanPitch';

  @override
  String get languageName => 'Español';

  @override
  String get languagePickerTitle => 'Elige tu idioma';

  @override
  String get languagePickerSubtitle => 'Puedes cambiarlo más tarde en Ajustes.';

  @override
  String get languagePickerContinue => 'Continuar';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingCreateAccount => 'Crear mi cuenta';

  @override
  String get onboardingAlreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get onboardingLiveTitle => 'El partido en directo\nen tu bolsillo.';

  @override
  String get onboardingLiveSubtitle =>
      'Sigue cada gol, tarjeta y momento mágico en tiempo real — incluso lejos de la tele.';

  @override
  String get onboardingTribeTitle => 'Reacciona con\ntu tribu.';

  @override
  String get onboardingTribeSubtitle =>
      'Emojis al vuelo, encuestas relámpago, comentarios que arden. Vive cada jugada con miles de aficionados.';

  @override
  String get onboardingWinTitle => 'Predice. Marca.\nBrilla.';

  @override
  String get onboardingWinSubtitle =>
      'Apuesta antes del pitido inicial, gana puntos, desbloquea insignias y sube en la clasificación.';

  @override
  String get onboardingReadyTitle => '¿Listo para saltar\nal campo?';

  @override
  String get onboardingReadySubtitle =>
      'Únete a la comunidad FanPitch en 30 segundos. Sin tarjeta de crédito — solo tu pasión.';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginUsername => 'Usuario';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginSubmit => 'Iniciar sesión';

  @override
  String get loginNoAccount => '¿Sin cuenta todavía? Regístrate';

  @override
  String get loginError => 'Usuario o contraseña incorrectos';

  @override
  String get loginNetworkError =>
      'No se puede conectar al servidor. Verifica tu conexión.';

  @override
  String get registerTitle => 'Crear una cuenta';

  @override
  String get registerDisplayName => 'Nombre a mostrar';

  @override
  String get registerUsername => 'Usuario';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Contraseña';

  @override
  String get registerCountry => 'País';

  @override
  String get registerCountryHint => 'Elige tu país';

  @override
  String get registerSubmit => 'Registrarse';

  @override
  String get registerHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String registerFailed(String error) {
    return 'Fallo al registrar: $error';
  }

  @override
  String get matchCompetition => 'Competición';

  @override
  String get matchVenue => 'Estadio';

  @override
  String matchMinute(int minute) {
    return '$minute\'';
  }

  @override
  String get matchStatsTitle => 'Estadísticas';

  @override
  String get matchStatsScorers => 'Goleadores';

  @override
  String get matchStatsCards => 'Tarjetas';

  @override
  String get matchStatsPossession => 'Posesión';

  @override
  String get matchStatsNoEvents => 'Sin eventos aún';

  @override
  String get tabForYou => 'Para ti';

  @override
  String get tabMatches => 'Partidos';

  @override
  String get tabMe => 'Yo';

  @override
  String get feedForYou => 'Para ti';

  @override
  String get feedFollowing => 'Siguiendo';

  @override
  String get feedEmptyForYou => 'Aún no hay publicaciones. Sé el primero 🔥';

  @override
  String get feedEmptyFollowing => 'Sigue a más fans para llenar este feed.';

  @override
  String get feedRefresh => 'Actualizar';

  @override
  String get feedRetry => 'Reintentar';

  @override
  String get feedLoadError => 'No se pudo cargar el feed.';

  @override
  String feedSeeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver los $count comentarios',
      one: 'Ver 1 comentario',
    );
    return '$_temp0';
  }

  @override
  String get createTitle => 'Nueva publicación';

  @override
  String get createPost => 'Publicar';

  @override
  String get createHint => '¿Cuál es el ambiente? 🔥';

  @override
  String get createAddImage => 'Añadir imagen';

  @override
  String get createRemoveImage => 'Quitar imagen';

  @override
  String get createAutoExpires => 'Las publicaciones expiran tras 7 días.';

  @override
  String createPostFailed(String error) {
    return 'Fallo al publicar: $error';
  }

  @override
  String get captionStudioTitle => 'Estudio de Subtítulos IA';

  @override
  String get captionStudioIntro =>
      'Describe el momento en tu idioma, la IA escribe la frase perfecta.';

  @override
  String get captionStudioBriefHint =>
      'Ej: fans congoleños bailando tras el gol...';

  @override
  String get captionStudioGenerate => 'Generar frase';

  @override
  String get captionStudioUse => 'Usar';

  @override
  String get captionStudioRegenerate => 'Regenerar';

  @override
  String captionStudioFailed(String error) {
    return 'Fallo de la IA: $error';
  }

  @override
  String get profilePoints => 'Puntos';

  @override
  String get profileLevel => 'Nivel';

  @override
  String get profileCountry => 'País';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileLanguageChange => 'Cambiar idioma';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get matchesTitle => 'Partidos';

  @override
  String get matchStatusUpcoming => 'Próximos';

  @override
  String get matchStatusLive => 'En directo';

  @override
  String get matchStatusFinished => 'Finalizado';

  @override
  String get leaderboardTitle => 'Clasificación';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonError => 'Error';

  @override
  String get commonLoading => 'Cargando…';
}
