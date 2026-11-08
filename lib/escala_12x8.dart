enum Turno { embarque, folga }

// Normaliza a data (remove hora/minuto/segundo)
DateTime norm(DateTime d) => DateTime(d.year, d.month, d.day);

final Map<String, DateTime> datasBaseEscalas = {
  "1B": DateTime(2026, 2, 1),
  "2B": DateTime(2026, 2, 3),
  "1D": DateTime(2026, 2, 6),
  "2D": DateTime(2026, 2, 8),
  "1A": DateTime(2026, 2, 11),
  "2A": DateTime(2026, 2, 13),
  "1C": DateTime(2026, 2, 16),
  "2C": DateTime(2026, 2, 18),
};

// Posição (0-19) de um dia dentro do ciclo de 20 dias (12 embarcado + 8 folga)
int cicloNoDia(DateTime dia, DateTime base) {
  final diff = norm(dia).difference(norm(base)).inDays;
  return ((diff % 20) + 20) % 20;
}

Turno calcularTurno(DateTime dia, DateTime base) {
  return cicloNoDia(dia, base) < 12 ? Turno.embarque : Turno.folga;
}
