import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LcdColors {
  static const gold = Color(0xFFE4C524);
  static const goldSoft = Color(0xFFEFD447);
  static const goldDark = Color(0xFFB29A0E);
  static const goldInk = Color(0xFF7D6900);
  static const goldPale = Color(0xFFFAF4C9);

  static const navy = Color(0xFF21244A);
  static const navyDeep = Color(0xFF171A3A);
  static const navyDeepest = Color(0xFF11132F);
  static const navyPanel = Color(0xFF1D2044);
  static const navyElevated = Color(0xFF252954);
  static const navyLine = Color(0xFF333868);
  static const navyBorder = Color(0xFF4D5388);

  static const paper = Color(0xFFF3F4F8);
  static const paperAlt = Color(0xFFE9ECF3);
  static const white = Color(0xFFFFFFFF);
  static const lineLight = Color(0xFFD6DAE6);
  static const mutedLight = Color(0xFF505672);

  // Semantic aliases for dark portal & app surfaces
  static const bg = navyDeepest;
  static const bgElevated = navyDeep;
  static const panel = navyPanel;
  static const line = navyLine;
  static const muted = Color(0xFFB8BDD6);
  static const cream = Color(0xFFF4F5FA);
  static const ink = navyDeep;

  // Semantic state colors (4.5:1+ friendly on dark surfaces)
  static const danger = Color(0xFFF07178);
  static const success = Color(0xFF5AC48B);
  static const successDeep = Color(0xFF38B28B);
  static const info = Color(0xFF68B8E8);
  static const warning = Color(0xFFE88B4F);
  static const progress = Color(0xFFF0B429);
}

class LcdTheme {
  static ThemeData dark() {
    final inter = GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: LcdColors.cream,
      displayColor: LcdColors.cream,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LcdColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: LcdColors.gold,
        onPrimary: LcdColors.ink,
        secondary: LcdColors.goldSoft,
        onSecondary: LcdColors.ink,
        surface: LcdColors.bgElevated,
        onSurface: LcdColors.cream,
        surfaceContainerHighest: LcdColors.navyElevated,
        outline: LcdColors.line,
        error: LcdColors.danger,
        onError: LcdColors.ink,
      ),
      textTheme: inter.copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 38,
          fontWeight: FontWeight.w500,
          color: LcdColors.cream,
          height: 1.12,
          letterSpacing: -0.6,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: LcdColors.cream,
          height: 1.14,
          letterSpacing: -0.4,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 25,
          fontWeight: FontWeight.w500,
          color: LcdColors.cream,
          height: 1.18,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 21,
          fontWeight: FontWeight.w500,
          color: LcdColors.cream,
          height: 1.22,
        ),
        titleLarge: inter.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: LcdColors.cream,
        ),
        titleMedium: inter.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: LcdColors.cream,
        ),
        bodyMedium: inter.bodyMedium?.copyWith(
          color: LcdColors.cream,
          height: 1.5,
        ),
        bodySmall: inter.bodySmall?.copyWith(
          color: LcdColors.muted,
          height: 1.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: LcdColors.bgElevated,
        foregroundColor: LcdColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: LcdColors.cream,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LcdColors.bgElevated,
        indicatorColor: LcdColors.gold.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? LcdColors.gold : LcdColors.muted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? LcdColors.gold : LcdColors.muted,
          );
        }),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: LcdColors.gold,
        labelColor: LcdColors.gold,
        unselectedLabelColor: LcdColors.muted,
        dividerColor: LcdColors.line,
      ),
      cardTheme: CardThemeData(
        color: LcdColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: LcdColors.line),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: LcdColors.navyElevated,
        side: const BorderSide(color: LcdColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        labelStyle: const TextStyle(color: LcdColors.cream, fontSize: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: LcdColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: LcdColors.line),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LcdColors.navyElevated,
        contentTextStyle: const TextStyle(color: LcdColors.cream),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: LcdColors.gold),
        ),
      ),
      dividerColor: LcdColors.line,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LcdColors.panel,
        labelStyle: const TextStyle(color: LcdColors.muted),
        hintStyle: TextStyle(color: LcdColors.muted.withValues(alpha: 0.72)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LcdColors.navyBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LcdColors.navyBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LcdColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LcdColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LcdColors.danger, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LcdColors.gold,
          foregroundColor: LcdColors.ink,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LcdColors.cream,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: LcdColors.navyBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LcdColors.gold,
          minimumSize: const Size(48, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

Color statusColor(String estado) {
  return switch (estado) {
    'em_avaliacao' || 'pendente' => LcdColors.gold,
    'por_iniciar' => const Color(0xFF9BA6C9),
    'em_processamento' => LcdColors.progress,
    'em_espera' => LcdColors.warning,
    'em_prova' => LcdColors.info,
    'concluido' || 'aceite' => LcdColors.success,
    'entregue' => LcdColors.successDeep,
    'recusado' || 'recusada' || 'cancelado' => LcdColors.danger,
    _ => LcdColors.muted,
  };
}

String estadoNome(String estado, {bool isClinica = false}) {
  if (isClinica) {
    return switch (estado) {
      'em_avaliacao' => 'Por aceitar',
      'concluido' || 'entregue' => 'Concluído',
      'recusado' => 'Recusado',
      'cancelado' => 'Cancelado',
      _ => 'Em produção',
    };
  }
  return switch (estado) {
    'em_avaliacao' => 'Em avaliação',
    'por_iniciar' => 'Por iniciar',
    'em_processamento' => 'Em produção',
    'em_espera' => 'Em espera',
    'em_prova' => 'Em prova',
    'concluido' => 'Concluído',
    'entregue' => 'Entregue',
    'recusado' => 'Recusado',
    'recusada' => 'Recusada',
    'cancelado' => 'Cancelado',
    'aceite' => 'Aceite',
    'pendente' => 'Pendente',
    _ => estado,
  };
}

String papelNome(String papel) {
  return switch (papel) {
    'clinica' => 'Clínica parceira',
    'admin' => 'Direção do laboratório',
    'tecnico' => 'Técnico de prótese',
    _ => papel,
  };
}

String permissaoNome(String permissao) {
  return switch (permissao) {
    'trabalhos' => 'Trabalhos e bancada',
    'pilha' => 'Fila de produção',
    'solicitacoes' => 'Solicitações',
    'configuracao' => 'Tipos e etapas',
    'clientes' => 'Clínicas parceiras',
    _ => permissao,
  };
}

String solicitacaoTipoNome(String tipo) {
  return switch (tipo) {
    'conserto' => 'Conserto',
    'reabertura' => 'Reabertura',
    'cancelamento' => 'Cancelamento',
    _ => tipo,
  };
}

String formatDoctorName(String nome) {
  final clean = nome.trim();
  if (clean.isEmpty) return 'Médico não indicado';
  if (RegExp(r'^(Dr\.|Dra\.|Dr\(a\)\.)\s', caseSensitive: false).hasMatch(clean)) {
    return clean;
  }
  return 'Dr(a). $clean';
}

String formatOmd(String numero) {
  final clean = numero.replaceFirst(RegExp(r'^OMD\s*', caseSensitive: false), '').trim();
  return clean.isEmpty ? 'OMD —' : 'OMD $clean';
}

String pluralPt(int count, String singular, String plural) => '$count ${count == 1 ? singular : plural}';
