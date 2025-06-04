enum Turno { manha, tarde, noite }

// Helper para obter o nome do turno para exibição
String nomeDoTurno(Turno turno) {
  switch (turno) {
    case Turno.manha:
      return 'Manhã';
    case Turno.tarde:
      return 'Tarde';
    case Turno.noite:
      return 'Noite';
    default:
      return '';
  }
}
