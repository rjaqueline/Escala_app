import 'package:escala_app/escala_12x8.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProximoMesPage extends StatefulWidget {
  final String escala;
  final int ano;
  final int mes;
  final bool isLider;

  const ProximoMesPage({
    super.key,
    required this.escala,
    required this.ano,
    required this.mes,
    this.isLider = false,
  });

  @override
  State<ProximoMesPage> createState() => _ProximoMesPageState();
}

class _ProximoMesPageState extends State<ProximoMesPage> {
  bool _mostrarMovimentacao = true;

  // -------- GERAR ESCALA DO MÊS --------
  List<Map<String, dynamic>> gerarEscalaDoMes() {
    final ultimoDia = DateTime(widget.ano, widget.mes + 1, 0).day;
    final base = datasBaseEscalas[widget.escala]!;

    final lista = <Map<String, dynamic>>[];

    for (int dia = 1; dia <= ultimoDia; dia++) {
      final data = DateTime(widget.ano, widget.mes, dia);
      final turno = calcularTurno(data, base);
      lista.add({'data': data, 'turno': turno});
    }

    return lista;
  }

  /// Turmas que EMBARCAM nesse dia (ciclo == 0 = primeiro dia embarcada)
  List<String> _turmasEmbarcando(DateTime dia) {
    final result = <String>[];
    for (final entry in datasBaseEscalas.entries) {
      final ciclo = cicloNoDia(dia, entry.value);
      if (ciclo == 0) result.add(entry.key);
    }
    result.sort();
    return result;
  }

  /// Turmas que DESEMBARCAM nesse dia (ciclo == 11 = último dia embarcada)
  List<String> _turmasDesembarcando(DateTime dia) {
    final result = <String>[];
    for (final entry in datasBaseEscalas.entries) {
      final ciclo = cicloNoDia(dia, entry.value);
      if (ciclo == 11) result.add(entry.key);
    }
    result.sort();
    return result;
  }

  /// Dia da semana abreviado
  String _diaSemana(DateTime data) {
    const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return dias[data.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM');
    final dias = gerarEscalaDoMes();

    final hoje = DateTime.now();
    final hojeLimpo = DateTime(hoje.year, hoje.month, hoje.day);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: Text(
          'Escala ${widget.escala} – ${toBeginningOfSentenceCase(DateFormat.MMMM("pt_BR").format(DateTime(widget.ano, widget.mes)))} ${widget.ano}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3A2D6B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.isLider)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _mostrarMovimentacao = !_mostrarMovimentacao;
                  });
                },
                tooltip: _mostrarMovimentacao
                    ? "Ocultar movimentação"
                    : "Mostrar movimentação",
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    _mostrarMovimentacao
                        ? Icons.groups_rounded
                        : Icons.person_rounded,
                    key: ValueKey(_mostrarMovimentacao),
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Banner de visão líder
          if (widget.isLider)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: _mostrarMovimentacao
                  ? const Color(0xFF3A2D6B).withValues(alpha: 0.08)
                  : Colors.transparent,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _mostrarMovimentacao
                    ? Row(
                        key: const ValueKey('lider_on'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 14,
                            color: const Color(0xFF3A2D6B).withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Visão Líder ativa — mostrando todas as turmas",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3A2D6B).withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('lider_off')),
              ),
            ),

          // Lista de dias
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: dias.length,
              itemBuilder: (context, index) {
                final item = dias[index];
                final data = item['data'] as DateTime;
                final turno = item['turno'] as Turno;

                final embarcada = turno == Turno.embarque;
                final status = embarcada ? "Embarcado(a)" : "Folga";
                final diaSemana = _diaSemana(data);

                final isHoje = data == hojeLimpo;
                final isFimDeSemana = data.weekday == 6 || data.weekday == 7;

                // Movimentação só aparece se líder E toggle ativo
                final bool mostrarTags = widget.isLider && _mostrarMovimentacao;
                final turmasIn = mostrarTags
                    ? _turmasEmbarcando(data)
                    : <String>[];
                final turmasOut = mostrarTags
                    ? _turmasDesembarcando(data)
                    : <String>[];
                final temMovimentacao =
                    turmasIn.isNotEmpty || turmasOut.isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: embarcada
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isHoje
                          ? (embarcada
                                ? Colors.red.shade400
                                : Colors.green.shade400)
                          : (embarcada
                                ? Colors.red.shade200
                                : Colors.green.shade200),
                      width: isHoje ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- LINHA PRINCIPAL ----
                      Row(
                        children: [
                          Icon(
                            embarcada
                                ? Icons.directions_bus_filled_rounded
                                : Icons.airline_seat_individual_suite,
                            color: embarcada
                                ? Colors.red.shade600
                                : Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            df.format(data),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: embarcada
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isFimDeSemana
                                  ? (embarcada
                                        ? Colors.red.shade100
                                        : Colors.green.shade100)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              diaSemana,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isFimDeSemana
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: embarcada
                                    ? Colors.red.shade400
                                    : Colors.green.shade400,
                              ),
                            ),
                          ),
                          if (isHoje) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: embarcada
                                    ? Colors.red.shade600
                                    : Colors.green.shade600,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "HOJE",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: embarcada
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),

                      // ---- TAGS DE MOVIMENTAÇÃO (SÓ LÍDER) ----
                      if (temMovimentacao) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            ...turmasIn.map(
                              (t) => _buildMovTag(turma: t, tipo: "embarca"),
                            ),
                            ...turmasOut.map(
                              (t) => _buildMovTag(turma: t, tipo: "desembarca"),
                            ),
                          ],
                        ),
                      ] else if (mostrarTags) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Sem movimentações",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Tag compacta de movimentação
  Widget _buildMovTag({required String turma, required String tipo}) {
    final bool isEmbarque = tipo == "embarca";
    final Color bgColor = isEmbarque
        ? const Color(0xFFE3F2FD)
        : const Color(0xFFFFF3E0);
    final Color textColor = isEmbarque
        ? const Color(0xFF1565C0)
        : const Color(0xFFE65100);
    final IconData icon = isEmbarque
        ? Icons.login_rounded
        : Icons.logout_rounded;
    final String label = isEmbarque ? "Embarca" : "Desembarca";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            "$turma $label",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
