OPCODES = {
  # addition
  addr: ->(reg, a, b, c) { reg[c] = reg[a] + reg[b] },
  addi: ->(reg, a, b, c) { reg[c] = reg[a] + b },
  # multiplication
  mulr: ->(reg, a, b, c) { reg[c] = reg[a] * reg[b] },
  muli: ->(reg, a, b, c) { reg[c] = reg[a] * b },
  # bitwise AND
  banr: ->(reg, a, b, c) { reg[c] = reg[a] & reg[b] },
  bani: ->(reg, a, b, c) { reg[c] = reg[a] & b },
  # bitwise OR
  borr: ->(reg, a, b, c) { reg[c] = reg[a] | reg[b] },
  bori: ->(reg, a, b, c) { reg[c] = reg[a] | b },
  # assignment
  setr: ->(reg, a, b, c) { reg[c] = reg[a] },
  seti: ->(reg, a, b, c) { reg[c] = a },
  # greater-than testing
  gtir: ->(reg, a, b, c) { reg[c] = a > reg[b] ? 1 : 0 },
  gtri: ->(reg, a, b, c) { reg[c] = reg[a] > b ? 1 : 0 },
  gtrr: ->(reg, a, b, c) { reg[c] = reg[a] > reg[b] ? 1 : 0 },
  # equality testing
  eqir: ->(reg, a, b, c) { reg[c] = a == reg[b] ? 1 : 0 },
  eqri: ->(reg, a, b, c) { reg[c] = reg[a] == b ? 1 : 0 },
  eqrr: ->(reg, a, b, c) { reg[c] = reg[a] == reg[b] ? 1 : 0 },
}

TRANSLATIONS = {
  # addition
  addr: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} + Reg #{b}" },
  addi: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} + #{b}" },
  # multiplication
  mulr: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} * Reg #{b}" },
  muli: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} * #{b}" },
  # bitwise AND
  banr: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} & Reg #{b}" },
  bani: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} & #{b}" },
  # bitwise OR
  borr: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} | Reg #{b}" },
  bori: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} | #{b}" },
  # assignment
  setr: ->(reg, a, b, c) { "Reg #{c} = Reg #{a}" },
  seti: ->(reg, a, b, c) { "Reg #{c} = #{a}" },
  # greater-than testing
  gtir: ->(reg, a, b, c) { "Reg #{c} = #{a} > Reg #{b}" },
  gtri: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} > #{b}" },
  gtrr: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} > Reg #{b}" },
  # equality testing
  eqir: ->(reg, a, b, c) { "Reg #{c} = #{a} == Reg #{b}" },
  eqri: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} == #{b}" },
  eqrr: ->(reg, a, b, c) { "Reg #{c} = Reg #{a} == Reg #{b}" },
}
