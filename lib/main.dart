// ============================================================
// ESCALA+ — Redesign UI 
// ============================================================
// Imports organizados
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:package_info_plus/package_info_plus.dart';

import 'escala_12x8.dart';
import 'proximo_mes_page.dart';
import 'perfil_selecao_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await initializeDateFormatting('pt_BR', null);

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const EscalaApp());
}

// ============================================================
// CORES E CONSTANTES DO TEMA
// ============================================================
class AppColors {
  static const Color primary = Color(0xFF3A2D6B); // Roxo profundo
  static const Color primaryLight = Color(0xFF5B4FA0); // Roxo médio
  static const Color primarySoft = Color(0xFFEDE9F6); // Roxo bem clarinho
  static const Color surface = Color(0xFFF8F7FC); // Fundo geral
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color embarked = Color(0xFFD32F2F);
  static const Color embarkedBg = Color(0xFFFFF0F0);
  static const Color offDuty = Color(0xFF2E7D32);
  static const Color offDutyBg = Color(0xFFF0F8F0);
  static const Color accent = Color(0xFFFF9800);
}

class EscalaApp extends StatefulWidget {
  const EscalaApp({super.key});

  @override
  State<EscalaApp> createState() => _EscalaAppState();
}

class _EscalaAppState extends State<EscalaApp> {
  bool _carregando = true;
  String? _perfil;

  @override
  void initState() {
    super.initState();
    _verificarPerfil();
  }

  Future<void> _verificarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _perfil = prefs.getString('perfil');
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escala+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: _carregando
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _perfil == null
          ? PerfilSelecaoPage(onPerfilSelecionado: () => _verificarPerfil())
          : const EscalaHome(),
    );
  }
}

class EscalaHome extends StatefulWidget {
  const EscalaHome({super.key});

  @override
  State<EscalaHome> createState() => _EscalaHomeState();
}

class _EscalaHomeState extends State<EscalaHome> {
  // ---------- ESTADO ----------
  DateTime? dataBase;
  String status = "";
  int diasRestantes = 0;
  String turmaSelecionada = "1A";
  String proximaMudancaTexto = "";
  int mesSelecionado = DateTime.now().month;
  int anoSelecionado = DateTime.now().year;
  String perfil = "colaborador"; // "colaborador" ou "lider"
  String appVersion = "";

  static const List<String> turmas = [
    "1A",
    "1B",
    "1C",
    "1D",
    "2A",
    "2B",
    "2C",
    "2D",
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  // ---------- PERSISTÊNCIA ----------
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final turma = prefs.getString('turma') ?? '1A';
    final perfilSalvo = prefs.getString('perfil') ?? 'colaborador';
    setState(() {
      turmaSelecionada = turma;
      perfil = perfilSalvo;
      dataBase = datasBaseEscalas[turmaSelecionada];
      _calcularStatus();
    });
  }

  void _onTurmaChanged(String? value) async {
    if (value != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('turma', value);
      setState(() {
        turmaSelecionada = value;
        dataBase = datasBaseEscalas[turmaSelecionada];
        _calcularStatus();
      });
      await scheduleNextTravelNotification(dataBase!);
    }
  }

  void _atualizarStatusManual() {
    setState(() {
      _calcularStatus();
    });
  }

  // Tipo de dia especial: embarque, desembarque, ou normal
  String diaEspecial = ""; // "", "embarque", "desembarque"

  // ---------- LÓGICA DE NEGÓCIO ----------
  void _calcularStatus() {
    if (dataBase == null) return;
    final hojeLimpo = norm(DateTime.now());
    final ciclo = cicloNoDia(hojeLimpo, dataBase!);

    // Detectar dia especial
    if (ciclo == 0) {
      diaEspecial = "embarque";
    } else if (ciclo == 11) {
      diaEspecial = "desembarque";
    } else {
      diaEspecial = "";
    }

    late DateTime proximaMudanca;
    if (ciclo < 12) {
      status = "Embarcada";
      diasRestantes = 12 - ciclo;
      proximaMudanca = hojeLimpo.add(Duration(days: diasRestantes - 1));
    } else {
      status = "De folga";
      diasRestantes = 20 - ciclo;
      proximaMudanca = hojeLimpo.add(Duration(days: diasRestantes));
    }
    final df = DateFormat('dd/MM/yyyy');
    proximaMudancaTexto = (status == "Embarcada")
        ? "Próximo desembarque: ${df.format(proximaMudanca)}"
        : "Próximo embarque: ${df.format(proximaMudanca)}";
  }

  // ---------- CONFIGURAÇÕES ----------
  void _mostrarConfiguracoes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Configurações",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Perfil atual
              const Text(
                "Seu perfil",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Opção Colaborador
              _buildPerfilOption(
                icon: Icons.person_rounded,
                titulo: "Colaborador",
                descricao: "Escala simples e direta",
                selecionado: perfil == 'colaborador',
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('perfil', 'colaborador');
                  setState(() => perfil = 'colaborador');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),

              // Opção Líder
              _buildPerfilOption(
                icon: Icons.groups_rounded,
                titulo: "Líder",
                descricao: "Veja movimentação de todas as turmas",
                selecionado: perfil == 'lider',
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('perfil', 'lider');
                  setState(() => perfil = 'lider');
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 24),

              // Divider
              Container(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
              const SizedBox(height: 16),

              // Sobre o app
              Center(
                child: Column(
                  children: [
                    Text(
                      appVersion.isEmpty ? "Escala+" : "Escala+ v$appVersion",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Desenvolvido por Jaqueline Batista",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerfilOption({
    required IconData icon,
    required String titulo,
    required String descricao,
    required bool selecionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selecionado
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selecionado
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.15),
            width: selecionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selecionado ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selecionado
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    descricao,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selecionado)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ---------- AVISOS ----------
  void _mostrarAvisos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.campaign_rounded,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Avisos Importantes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAvisoItem(
                icon: Icons.warning_amber_rounded,
                color: AppColors.accent,
                text:
                    "Antes de realizar qualquer viagem, confirme sua escala no sistema oficial.",
              ),
              const SizedBox(height: 14),
              _buildAvisoItem(
                icon: Icons.shield_rounded,
                color: AppColors.embarked,
                text:
                    "Não compartilhe sua escala com desconhecidos. Evite riscos de furtos durante sua viagem.",
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvisoItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // UI PRINCIPAL
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final bool isEmbarcada = status == "Embarcada";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- HEADER ROXO COM GRADIENTE ---
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3A2D6B), Color(0xFF5B4FA0)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    children: [
                      // Título + botões
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Escala+",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _mostrarConfiguracoes,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.settings_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _mostrarAvisos,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Subtítulo
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Selecione sua turma",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Grid de turmas
                      _buildTurmaGrid(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- CONTEÚDO ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                children: [
                  // Card de Status
                  _buildStatusCard(isEmbarcada),

                  const SizedBox(height: 14),

                  // Botão atualizar (compacto)
                  _buildActionButton(
                    icon: Icons.refresh_rounded,
                    label: "Atualizar Status",
                    onPressed: _atualizarStatusManual,
                    outlined: true,
                  ),

                  const SizedBox(height: 28),

                  // Seção calendário
                  _buildSectionTitle("Calendário"),

                  const SizedBox(height: 14),

                  // Seletores mês/ano
                  _buildMonthYearSelector(),

                  const SizedBox(height: 16),

                  // Botão ver escala
                  _buildActionButton(
                    icon: Icons.calendar_month_rounded,
                    label: "Ver escala do mês",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProximoMesPage(
                            escala: turmaSelecionada,
                            mes: mesSelecionado,
                            ano: anoSelecionado,
                            isLider: perfil == 'lider',
                          ),
                        ),
                      );
                    },
                    outlined: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGETS CUSTOMIZADOS
  // ============================================================

  /// Grid de turmas — 4 colunas, chips compactos
  Widget _buildTurmaGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: turmas.map((t) {
        final selecionada = (turmaSelecionada == t);
        return GestureDetector(
          onTap: () => _onTurmaChanged(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 68,
            height: 40,
            decoration: BoxDecoration(
              color: selecionada ? Colors.white : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selecionada
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
                width: selecionada ? 2 : 1,
              ),
              boxShadow: selecionada
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              t,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selecionada
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Card de status principal
  Widget _buildStatusCard(bool isEmbarcada) {
    final Color statusColor = isEmbarcada
        ? AppColors.embarked
        : AppColors.offDuty;
    final Color bgColor = isEmbarcada
        ? AppColors.embarkedBg
        : AppColors.offDutyBg;
    final IconData statusIcon = isEmbarcada
        ? Icons.directions_bus_filled_rounded
        : Icons.airline_seat_individual_suite_rounded;

    // Dia de viagem?
    final bool isDiaViagem =
        diaEspecial == "embarque" || diaEspecial == "desembarque";
    final Color viagemBannerColor = diaEspecial == "embarque"
        ? const Color(0xFFFF6F00) // Laranja forte
        : const Color(0xFF1565C0); // Azul

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra colorida no topo do card
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),

          // ---- BANNER DIA DE VIAGEM ----
          if (isDiaViagem)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(color: viagemBannerColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    diaEspecial == "embarque"
                        ? Icons.flight_takeoff_rounded
                        : Icons.flight_land_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    diaEspecial == "embarque"
                        ? "VOCÊ EMBARCA HOJE!"
                        : "VOCÊ DESEMBARCA HOJE!",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícone com fundo colorido
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status atual",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              status,
                              key: ValueKey(status),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge com dias restantes
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "$diasRestantes",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            "dias",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: statusColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider sutil
                Container(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                const SizedBox(height: 14),
                // Data próxima mudança ou mensagem de viagem
                Row(
                  children: [
                    Icon(
                      isDiaViagem ? Icons.luggage_rounded : Icons.event_rounded,
                      size: 16,
                      color: isDiaViagem
                          ? viagemBannerColor
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isDiaViagem
                            ? (diaEspecial == "embarque"
                                  ? "Hoje é dia de viagem! Boa jornada."
                                  : "Hoje é dia de voltar pra casa! Bom descanso.")
                            : proximaMudancaTexto,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDiaViagem
                              ? viagemBannerColor
                              : AppColors.textSecondary,
                          fontWeight: isDiaViagem
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Título de seção
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  /// Seletor de mês e ano com visual limpo
  Widget _buildMonthYearSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildDropdown<int>(
              value: mesSelecionado,
              label: "Mês",
              items: List.generate(12, (index) {
                final mes = index + 1;
                return DropdownMenuItem(
                  value: mes,
                  child: Text(
                    toBeginningOfSentenceCase(
                      DateFormat.MMMM("pt_BR").format(DateTime(2026, mes)),
                    )!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
              onChanged: (value) {
                if (value != null) setState(() => mesSelecionado = value);
              },
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey.withValues(alpha: 0.15)),
          Expanded(
            flex: 1,
            child: _buildDropdown<int>(
              value: anoSelecionado,
              label: "Ano",
              items: List.generate(15, (index) {
                final ano = DateTime.now().year - 5 + index;
                return DropdownMenuItem(
                  value: ano,
                  child: Text(
                    ano.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
              onChanged: (value) {
                if (value != null) setState(() => anoSelecionado = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isDense: true,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Botão de ação — pode ser preenchido (filled) ou outline
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool outlined,
  }) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            side: BorderSide(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

}

// ---------- NOTIFICAÇÕES EXTERNAS ----------
Future<void> scheduleNextTravelNotification(DateTime dataBase) async {
  final now = DateTime.now();
  for (int i = 0; i < 30; i++) {
    final candidate = DateTime(now.year, now.month, now.day + i);
    final diasDesde = candidate
        .difference(DateTime(dataBase.year, dataBase.month, dataBase.day))
        .inDays;
    final ciclo = ((diasDesde) % 20 + 20) % 20;

    if (ciclo == 0 || ciclo == 11) {
      final notificationDay = candidate.subtract(const Duration(days: 1));
      final scheduled = DateTime(
        notificationDay.year,
        notificationDay.month,
        notificationDay.day,
        8,
        0,
      );
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Viagem amanhã',
        'Amanhã é dia de viagem. Prepare-se!',
        tz.TZDateTime.from(scheduled, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'escala_channel',
            'Escala 12x8',
            channelDescription: 'Notificações de viagem',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      break;
    }
  }
}
