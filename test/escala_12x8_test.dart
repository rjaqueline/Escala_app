// Testes do cálculo do ciclo 12x8 (lib/escala_12x8.dart).
//
// As datas e os turnos esperados abaixo foram calculados à mão fora do
// código de produção (contando os dias a partir de cada data base) e depois
// conferidos independentemente com o utilitário `date` do GNU coreutils —
// não usam a fórmula de cicloNoDia/calcularTurno, para que o teste não vire
// uma tautologia.
import 'package:escala_app/escala_12x8.dart';
import 'package:flutter_test/flutter_test.dart';

class _Caso {
  final String turma;
  final DateTime data;
  final Turno turnoEsperado;
  final String descricao;

  const _Caso(this.turma, this.data, this.turnoEsperado, this.descricao);
}

// Não é `const`: DateTime não tem construtor const.
final casos = <_Caso>[
  // ---- 1B (base 01/02/2026) ----
  _Caso('1B', DateTime(2026, 2, 1), Turno.embarque, 'embarque'),
  _Caso('1B', DateTime(2026, 2, 12), Turno.embarque, 'desembarque (último dia embarcado)'),
  _Caso('1B', DateTime(2026, 2, 13), Turno.folga, 'primeiro dia de folga'),
  _Caso('1B', DateTime(2026, 2, 20), Turno.folga, 'último dia de folga'),
  _Caso('1B', DateTime(2026, 2, 21), Turno.embarque, 'novo embarque'),
  _Caso('1B', DateTime(2026, 1, 31), Turno.folga, 'um dia antes da data base'),
  _Caso('1B', DateTime(2026, 1, 12), Turno.embarque, '20 dias antes da data base (ciclo completo)'),
  _Caso('1B', DateTime(2026, 12, 31), Turno.folga, 'virada de ano — 31/12/2026'),
  _Caso('1B', DateTime(2027, 1, 1), Turno.folga, 'virada de ano — 01/01/2027'),

  // ---- 2B (base 03/02/2026) ----
  _Caso('2B', DateTime(2026, 2, 3), Turno.embarque, 'embarque'),
  _Caso('2B', DateTime(2026, 2, 14), Turno.embarque, 'desembarque (último dia embarcado)'),
  _Caso('2B', DateTime(2026, 2, 15), Turno.folga, 'primeiro dia de folga'),
  _Caso('2B', DateTime(2026, 2, 22), Turno.folga, 'último dia de folga'),
  _Caso('2B', DateTime(2026, 2, 23), Turno.embarque, 'novo embarque'),
  _Caso('2B', DateTime(2026, 2, 2), Turno.folga, 'um dia antes da data base'),
  _Caso('2B', DateTime(2026, 1, 14), Turno.embarque, '20 dias antes da data base (ciclo completo)'),
  _Caso('2B', DateTime(2026, 12, 31), Turno.embarque, 'virada de ano — 31/12/2026'),
  _Caso('2B', DateTime(2027, 1, 1), Turno.folga, 'virada de ano — 01/01/2027'),

  // ---- 1D (base 06/02/2026) ----
  _Caso('1D', DateTime(2026, 2, 6), Turno.embarque, 'embarque'),
  _Caso('1D', DateTime(2026, 2, 17), Turno.embarque, 'desembarque (último dia embarcado)'),
  _Caso('1D', DateTime(2026, 2, 18), Turno.folga, 'primeiro dia de folga'),
  _Caso('1D', DateTime(2026, 2, 25), Turno.folga, 'último dia de folga'),
  _Caso('1D', DateTime(2026, 2, 26), Turno.embarque, 'novo embarque'),
  _Caso('1D', DateTime(2026, 2, 5), Turno.folga, 'um dia antes da data base'),
  _Caso('1D', DateTime(2026, 1, 17), Turno.embarque, '20 dias antes da data base (ciclo completo)'),
  _Caso('1D', DateTime(2026, 12, 31), Turno.embarque, 'virada de ano — 31/12/2026'),
  _Caso('1D', DateTime(2027, 1, 1), Turno.embarque, 'virada de ano — 01/01/2027'),

  // ---- 2D (base 08/02/2026) ----
  _Caso('2D', DateTime(2026, 2, 8), Turno.embarque, 'embarque'),
  _Caso('2D', DateTime(2026, 2, 19), Turno.embarque, 'desembarque (último dia embarcado)'),
  _Caso('2D', DateTime(2026, 2, 20), Turno.folga, 'primeiro dia de folga'),
  _Caso('2D', DateTime(2026, 2, 27), Turno.folga, 'último dia de folga'),
  _Caso('2D', DateTime(2026, 2, 28), Turno.embarque, 'novo embarque'),
  _Caso('2D', DateTime(2026, 2, 7), Turno.folga, 'um dia antes da data base'),
  _Caso('2D', DateTime(2026, 1, 19), Turno.embarque, '20 dias antes da data base (ciclo completo)'),
  _Caso('2D', DateTime(2026, 12, 31), Turno.embarque, 'virada de ano — 31/12/2026'),
  _Caso('2D', DateTime(2027, 1, 1), Turno.embarque, 'virada de ano — 01/01/2027'),

  // ---- 1A (base 11/02/2026) ----
  _Caso('1A', DateTime(2026, 2, 11), Turno.embarque, 'embarque'),
  _Caso('1A', DateTime(2026, 2, 22), Turno.embarque, 'desembarque (último dia embarcado)'),
  _Caso('1A', DateTime(2026, 2, 23), Turno.folga, 'primeiro dia de folga'),
  _Caso('1A', DateTime(2026, 3, 2), Turno.folga, 'último dia de folga (virada de mês fev→mar)'),
  _Caso('1A', DateTime(2026, 3, 3), Turno.embarque, 'novo embarque (virada de mês fev→mar)'),
  _Caso('1A', DateTime(2026, 2, 10), Turno.folga, 'um dia antes da data base'),
  _Caso('1A', DateTime(2026, 1, 22), Turno.embarque, '20 dias antes da data base (ciclo completo)'),
  _Caso('1A', DateTime(2026, 12, 31), Turno.embarque, 'virada de ano — 31/12/2026'),
  _Caso('1A', DateTime(2027, 1, 1), Turno.embarque, 'virada de ano — 01/01/2027'),

  // ---- 2A (base 13/02/2026) ----
  _Caso('2A', DateTime(2026, 2, 13), Turno.embarque, 'embarque'),
  _Caso('2A', DateTime(2026, 2, 24), Turno.embarque, 'desembarque (último dia embarcado)'),
  _Caso('2A', DateTime(2026, 2, 25), Turno.folga, 'primeiro dia de folga'),
  _Caso('2A', DateTime(2026, 3, 4), Turno.folga, 'último dia de folga (virada de mês fev→mar)'),
  _Caso('2A', DateTime(2026, 3, 5), Turno.embarque, 'novo embarque (virada de mês fev→mar)'),
  _Caso('2A', DateTime(2026, 2, 12), Turno.folga, 'um dia antes da data base'),
  _Caso('2A', DateTime(2026, 1, 24), Turno.embarque, '20 dias antes da data base (ciclo completo)'),
  _Caso('2A', DateTime(2026, 12, 31), Turno.embarque, 'virada de ano — 31/12/2026'),
  _Caso('2A', DateTime(2027, 1, 1), Turno.embarque, 'virada de ano — 01/01/2027'),

  // ---- 1C (base 16/02/2026) ----
  _Caso('1C', DateTime(2026, 2, 16), Turno.embarque, 'embarque'),
  _Caso('1C', DateTime(2026, 2, 27), Turno.embarque, 'desembarque (último dia embarcado)'),
  _Caso('1C', DateTime(2026, 2, 28), Turno.folga, 'primeiro dia de folga'),
  _Caso('1C', DateTime(2026, 3, 7), Turno.folga, 'último dia de folga (virada de mês fev→mar)'),
  _Caso('1C', DateTime(2026, 3, 8), Turno.embarque, 'novo embarque (virada de mês fev→mar)'),
  _Caso('1C', DateTime(2026, 2, 15), Turno.folga, 'um dia antes da data base'),
  _Caso('1C', DateTime(2026, 1, 27), Turno.embarque, '20 dias antes da data base (ciclo completo)'),
  _Caso('1C', DateTime(2026, 12, 31), Turno.folga, 'virada de ano — 31/12/2026'),
  _Caso('1C', DateTime(2027, 1, 1), Turno.folga, 'virada de ano — 01/01/2027'),

  // ---- 2C (base 18/02/2026) ----
  _Caso('2C', DateTime(2026, 2, 18), Turno.embarque, 'embarque'),
  _Caso('2C', DateTime(2026, 3, 1), Turno.embarque, 'desembarque (último dia embarcado, virada de mês fev→mar)'),
  _Caso('2C', DateTime(2026, 3, 2), Turno.folga, 'primeiro dia de folga'),
  _Caso('2C', DateTime(2026, 3, 9), Turno.folga, 'último dia de folga'),
  _Caso('2C', DateTime(2026, 3, 10), Turno.embarque, 'novo embarque'),
  _Caso('2C', DateTime(2026, 2, 17), Turno.folga, 'um dia antes da data base'),
  _Caso('2C', DateTime(2026, 1, 29), Turno.embarque, '20 dias antes da data base (ciclo completo)'),
  _Caso('2C', DateTime(2026, 12, 31), Turno.folga, 'virada de ano — 31/12/2026'),
  _Caso('2C', DateTime(2027, 1, 1), Turno.folga, 'virada de ano — 01/01/2027'),
];

void main() {
  group('calcularTurno — ciclo de 20 dias (12 embarcado + 8 folga)', () {
    for (final c in casos) {
      final rotulo = '${c.data.year}-${c.data.month.toString().padLeft(2, '0')}'
          '-${c.data.day.toString().padLeft(2, '0')}';
      test('turma ${c.turma} em $rotulo — ${c.descricao}', () {
        final base = datasBaseEscalas[c.turma]!;
        expect(calcularTurno(c.data, base), c.turnoEsperado);
      });
    }
  });

  test('datasBaseEscalas contém exatamente as 8 turmas', () {
    expect(datasBaseEscalas.keys.toSet(), {
      '1A', '1B', '1C', '1D', '2A', '2B', '2C', '2D',
    });
  });
}
