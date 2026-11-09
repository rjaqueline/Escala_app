import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class PerfilSelecaoPage extends StatefulWidget {
  final VoidCallback onPerfilSelecionado;

  const PerfilSelecaoPage({super.key, required this.onPerfilSelecionado});

  @override
  State<PerfilSelecaoPage> createState() => _PerfilSelecaoPageState();
}

class _PerfilSelecaoPageState extends State<PerfilSelecaoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selecionarPerfil(String perfil) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil', perfil);
    widget.onPerfilSelecionado();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.brandPurple,
                AppTheme.brandPurpleLight,
                Color(0xFF7B6FC0),
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo / Título
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        "Escala+",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Como você vai usar o app?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Card Colaborador
                      _buildPerfilCard(
                        icon: Icons.person_rounded,
                        titulo: "Colaborador",
                        descricao: "Veja sua escala de forma simples e rápida",
                        onTap: () => _selecionarPerfil('colaborador'),
                      ),

                      const SizedBox(height: 16),

                      // Card Líder
                      _buildPerfilCard(
                        icon: Icons.groups_rounded,
                        titulo: "Líder",
                        descricao:
                            "Acompanhe a movimentação de todas as turmas",
                        onTap: () => _selecionarPerfil('lider'),
                        destaque: true,
                      ),

                      const Spacer(flex: 3),

                      // Nota de rodapé
                      Text(
                        "Você pode alterar isso depois nas configurações",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilCard({
    required IconData icon,
    required String titulo,
    required String descricao,
    required VoidCallback onTap,
    bool destaque = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: destaque ? Colors.white : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: destaque
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            width: destaque ? 2 : 1,
          ),
          boxShadow: destaque
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: destaque
                    ? AppTheme.brandPurple.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 26,
                color: destaque ? AppTheme.brandPurple : Colors.white,
              ),
            ),
            const SizedBox(width: 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: destaque ? const Color(0xFF1A1A2E) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: TextStyle(
                      fontSize: 13,
                      color: destaque
                          ? const Color(0xFF6B6B80)
                          : Colors.white.withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Seta
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: destaque
                  ? AppTheme.brandPurple
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
