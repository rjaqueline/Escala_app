import 'package:flutter/material.dart';

/// Tema do app: claro (idêntico ao visual original, cores fixas) e
/// escuro (baseado na mesma semente roxa, com contraste ajustado pelo
/// Material 3). Cores de marca sólidas (header, botão principal,
/// gradiente da tela de perfil) ficam fixas em [AppTheme.brandPurple] /
/// [AppTheme.brandPurpleLight] — já têm contraste garantido por si
/// mesmas e não precisam variar entre os temas.
class AppTheme {
  AppTheme._();

  static const Color brandPurple = Color(0xFF3A2D6B);
  static const Color brandPurpleLight = Color(0xFF5B4FA0);

  static const List<Color> headerGradient = [brandPurple, brandPurpleLight];

  /// Linha divisória sutil — cinza claro sobre o card branco do tema
  /// claro, cinza claro translúcido sobre o card escuro do tema escuro.
  static const Color _dividerLight = Color(0x1A000000); // grey, alpha ~0.1
  static const Color _dividerDark = Color(0x1EFFFFFF); // white, alpha ~0.12

  static final ThemeData lightTheme = _buildTheme(
    colorScheme: const ColorScheme.light(
      primary: brandPurple,
      onPrimary: Colors.white,
      secondary: brandPurpleLight,
      onSecondary: Colors.white,
      surface: Color(0xFFF8F7FC),
      onSurface: Color(0xFF1A1A2E),
    ).copyWith(onSurfaceVariant: const Color(0xFF6B6B80)),
    cardColor: Colors.white,
    dividerColor: _dividerLight,
    statusColors: StatusColors.light,
  );

  static final ThemeData darkTheme = _buildTheme(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: brandPurple,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF17151F),
          onSurface: const Color(0xFFECEAF5),
          onSurfaceVariant: const Color(0xFFABA8C2),
        ),
    cardColor: const Color(0xFF201D2B),
    dividerColor: _dividerDark,
    statusColors: StatusColors.dark,
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color cardColor,
    required Color dividerColor,
    required StatusColors statusColors,
  }) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: cardColor,
      dividerColor: dividerColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      extensions: [statusColors],
    );
  }
}

/// Cores de status (embarcado/folga, banners de viagem, tags de
/// movimentação e aviso) com versões claras e escuras. Os fundos claros
/// de hoje (embarkedBg, offDutyBg etc.) ficariam "estourados" sobre uma
/// tela escura, então cada papel tem sua própria variante escura —
/// fundos foscos/profundos em vez de pastéis.
class StatusColors extends ThemeExtension<StatusColors> {
  final Color embarked;
  final Color embarkedBg;
  final Color embarkedBorder;
  final Color offDuty;
  final Color offDutyBg;
  final Color offDutyBorder;
  final Color travelDeparture;
  final Color travelArrival;
  final Color tagInBg;
  final Color tagInFg;
  final Color tagOutBg;
  final Color tagOutFg;
  final Color warning;

  const StatusColors({
    required this.embarked,
    required this.embarkedBg,
    required this.embarkedBorder,
    required this.offDuty,
    required this.offDutyBg,
    required this.offDutyBorder,
    required this.travelDeparture,
    required this.travelArrival,
    required this.tagInBg,
    required this.tagInFg,
    required this.tagOutBg,
    required this.tagOutFg,
    required this.warning,
  });

  static const StatusColors light = StatusColors(
    embarked: Color(0xFFD32F2F),
    embarkedBg: Color(0xFFFFF0F0),
    embarkedBorder: Color(0xFFEF9A9A),
    offDuty: Color(0xFF2E7D32),
    offDutyBg: Color(0xFFF0F8F0),
    offDutyBorder: Color(0xFFA5D6A7),
    travelDeparture: Color(0xFFFF6F00),
    travelArrival: Color(0xFF1565C0),
    tagInBg: Color(0xFFE3F2FD),
    tagInFg: Color(0xFF1565C0),
    tagOutBg: Color(0xFFFFF3E0),
    tagOutFg: Color(0xFFE65100),
    warning: Color(0xFFFF9800),
  );

  static const StatusColors dark = StatusColors(
    embarked: Color(0xFFFF6B6B),
    embarkedBg: Color(0xFF3D1F1F),
    embarkedBorder: Color(0xFF5C2E2E),
    offDuty: Color(0xFF6FCF7A),
    offDutyBg: Color(0xFF1C3320),
    offDutyBorder: Color(0xFF345A3A),
    travelDeparture: Color(0xFFE65100),
    travelArrival: Color(0xFF0D47A1),
    tagInBg: Color(0xFF13293D),
    tagInFg: Color(0xFF64B5F6),
    tagOutBg: Color(0xFF3D2A12),
    tagOutFg: Color(0xFFFFB74D),
    warning: Color(0xFFFFB74D),
  );

  @override
  StatusColors copyWith({
    Color? embarked,
    Color? embarkedBg,
    Color? embarkedBorder,
    Color? offDuty,
    Color? offDutyBg,
    Color? offDutyBorder,
    Color? travelDeparture,
    Color? travelArrival,
    Color? tagInBg,
    Color? tagInFg,
    Color? tagOutBg,
    Color? tagOutFg,
    Color? warning,
  }) {
    return StatusColors(
      embarked: embarked ?? this.embarked,
      embarkedBg: embarkedBg ?? this.embarkedBg,
      embarkedBorder: embarkedBorder ?? this.embarkedBorder,
      offDuty: offDuty ?? this.offDuty,
      offDutyBg: offDutyBg ?? this.offDutyBg,
      offDutyBorder: offDutyBorder ?? this.offDutyBorder,
      travelDeparture: travelDeparture ?? this.travelDeparture,
      travelArrival: travelArrival ?? this.travelArrival,
      tagInBg: tagInBg ?? this.tagInBg,
      tagInFg: tagInFg ?? this.tagInFg,
      tagOutBg: tagOutBg ?? this.tagOutBg,
      tagOutFg: tagOutFg ?? this.tagOutFg,
      warning: warning ?? this.warning,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      embarked: Color.lerp(embarked, other.embarked, t)!,
      embarkedBg: Color.lerp(embarkedBg, other.embarkedBg, t)!,
      embarkedBorder: Color.lerp(embarkedBorder, other.embarkedBorder, t)!,
      offDuty: Color.lerp(offDuty, other.offDuty, t)!,
      offDutyBg: Color.lerp(offDutyBg, other.offDutyBg, t)!,
      offDutyBorder: Color.lerp(offDutyBorder, other.offDutyBorder, t)!,
      travelDeparture: Color.lerp(travelDeparture, other.travelDeparture, t)!,
      travelArrival: Color.lerp(travelArrival, other.travelArrival, t)!,
      tagInBg: Color.lerp(tagInBg, other.tagInBg, t)!,
      tagInFg: Color.lerp(tagInFg, other.tagInFg, t)!,
      tagOutBg: Color.lerp(tagOutBg, other.tagOutBg, t)!,
      tagOutFg: Color.lerp(tagOutFg, other.tagOutFg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension StatusColorsContext on BuildContext {
  StatusColors get statusColors => Theme.of(this).extension<StatusColors>()!;
}
