# db/seeds.rb
#
# Quiniela Mundial 2026 — Fase de eliminación directa (32 partidos)
# ---------------------------------------------------------------------------
# Esquema asumido (migración sugerida — corre esto primero):
#
#   create_table :matches do |t|
#     t.integer  :number,        null: false   # número oficial FIFA (73–104)
#     t.string   :stage,         null: false   # r32, r16, qf, sf, third, final
#     t.string   :home_label                   # etiqueta display antes de saber equipos ("2A", "Ganador P74")
#     t.string   :away_label
#     t.integer  :home_source_number           # partido del que sale el equipo local (nil en R32)
#     t.integer  :away_source_number
#     t.string   :home_source_result           # "winner" / "loser"
#     t.string   :away_source_result
#     t.string   :home_team                    # se llena cuando se conoce
#     t.string   :away_team
#     t.integer  :home_score
#     t.integer  :away_score
#     t.string   :advancing_team               # quién avanza (resuelve penales)
#     t.datetime :kickoff_at
#     t.string   :venue
#     t.string   :status,        default: "scheduled"  # scheduled, live, finished
#     t.timestamps
#   end
#   add_index :matches, :number, unique: true
#
# ---------------------------------------------------------------------------
# OJO — tres cosas antes de lanzar:
#
#   1. HORARIOS: kickoff_at está en UTC. Los que tienen hora confirmada (ET)
#      ya están convertidos; el resto son PLACEHOLDER. Verifica todos contra
#      el calendario oficial de FIFA antes de lanzar — la lógica de lock
#      depende de kickoff_at y las sedes cruzan 4 husos horarios.
#
#   2. EQUIPOS R32: home_team/away_team van vacíos. Los grupos cierran el
#      27 de junio; esa noche llenas los 16 cruces con equipos reales.
#      Las home_label/away_label son posiciones de grupo (2A, 1E, etc.).
#
#   3. PARTIDOS 82–85: aún sin etiqueta de posición pública confirmada al
#      momento de armar esto. Quedan como "Por definir"; se concretan con
#      los mejores terceros. El ÁRBOL (qué partido alimenta a cuál) sí está
#      confirmado, que es lo que importa para el bracket.
# ---------------------------------------------------------------------------

# Puntos por ronda (peso para que el título no se decida solo en R32).
# Úsalo en tu lógica de scoring, no en el seed.
POINTS_BY_STAGE = {
  "r32"   => 1,
  "r16"   => 2,
  "qf"    => 3,
  "sf"    => 5,
  "third" => 3,
  "final" => 8
}.freeze

def t(year, month, day, hour, min = 0)
  Time.utc(year, month, day, hour, min)
end

MATCHES = [
  # ───────── DIECISEISAVOS (R32) — equipos salen de la fase de grupos ─────────
  { number: 73, stage: "r32", home_label: "2A",         away_label: "2B",          venue: "Los Ángeles",            kickoff_at: t(2026, 6, 28, 19, 0) },
  { number: 74, stage: "r32", home_label: "1E",         away_label: "3º A/B/C/D/F", venue: "Boston",                 kickoff_at: t(2026, 6, 29, 20, 30) },
  { number: 75, stage: "r32", home_label: "1F",         away_label: "2C",          venue: "Monterrey",              kickoff_at: t(2026, 6, 29, 1, 0) },
  { number: 76, stage: "r32", home_label: "1C",         away_label: "2F",          venue: "Houston",                kickoff_at: t(2026, 6, 28, 17, 0) },
  { number: 77, stage: "r32", home_label: "1I",         away_label: "3º C/D/F/G/H", venue: "Nueva York/Nueva Jersey", kickoff_at: t(2026, 6, 29, 21, 0) },
  { number: 78, stage: "r32", home_label: "2E",         away_label: "2I",          venue: "Dallas",                 kickoff_at: t(2026, 6, 29, 17, 0) },
  { number: 79, stage: "r32", home_label: "1A",         away_label: "3º C/E/G/H/I", venue: "Ciudad de México",       kickoff_at: t(2026, 6, 29, 1, 0) },
  { number: 80, stage: "r32", home_label: "1L",         away_label: "3º E/H/I/J/K", venue: "Atlanta",                kickoff_at: t(2026, 6, 30, 16, 0) },
  { number: 81, stage: "r32", home_label: "1D",         away_label: "Mejor 3º",     venue: "Bahía de San Francisco", kickoff_at: t(2026, 6, 30, 20, 0) },   # TODO verificar hora
  { number: 82, stage: "r32", home_label: "Por definir", away_label: "Por definir", venue: "Seattle",                kickoff_at: t(2026, 7, 1, 20, 0) },    # TODO verificar
  { number: 83, stage: "r32", home_label: "Por definir", away_label: "Por definir", venue: nil,                      kickoff_at: t(2026, 7, 1, 23, 0) },    # TODO verificar
  { number: 84, stage: "r32", home_label: "Por definir", away_label: "Por definir", venue: nil,                      kickoff_at: t(2026, 7, 2, 20, 0) },    # TODO verificar
  { number: 85, stage: "r32", home_label: "Por definir", away_label: "Por definir", venue: nil,                      kickoff_at: t(2026, 7, 2, 23, 0) },    # TODO verificar
  { number: 86, stage: "r32", home_label: "1J",         away_label: "2H",          venue: "Miami",                  kickoff_at: t(2026, 7, 2, 22, 0) },
  { number: 87, stage: "r32", home_label: "1K",         away_label: "3º D/E/I/J/L", venue: "Kansas City",            kickoff_at: t(2026, 7, 4, 1, 30) },
  { number: 88, stage: "r32", home_label: "2D",         away_label: "2G",          venue: "Dallas",                 kickoff_at: t(2026, 7, 3, 18, 0) },

  # ───────── OCTAVOS (R16) — ganadores de R32 ─────────
  { number: 89, stage: "r16", home_label: "Ganador P74", away_label: "Ganador P77", home_source_number: 74, away_source_number: 77, venue: "Filadelfia",              kickoff_at: t(2026, 7, 4, 21, 0) },
  { number: 90, stage: "r16", home_label: "Ganador P73", away_label: "Ganador P75", home_source_number: 73, away_source_number: 75, venue: "Houston",                 kickoff_at: t(2026, 7, 4, 17, 0) },
  { number: 91, stage: "r16", home_label: "Ganador P76", away_label: "Ganador P78", home_source_number: 76, away_source_number: 78, venue: "Nueva York/Nueva Jersey", kickoff_at: t(2026, 7, 5, 20, 0) },
  { number: 92, stage: "r16", home_label: "Ganador P79", away_label: "Ganador P80", home_source_number: 79, away_source_number: 80, venue: "Ciudad de México",        kickoff_at: t(2026, 7, 6, 0, 0) },
  { number: 93, stage: "r16", home_label: "Ganador P83", away_label: "Ganador P84", home_source_number: 83, away_source_number: 84, venue: "Dallas",                  kickoff_at: t(2026, 7, 6, 19, 0) },
  { number: 94, stage: "r16", home_label: "Ganador P81", away_label: "Ganador P82", home_source_number: 81, away_source_number: 82, venue: "Seattle",                 kickoff_at: t(2026, 7, 7, 0, 0) },
  { number: 95, stage: "r16", home_label: "Ganador P86", away_label: "Ganador P88", home_source_number: 86, away_source_number: 88, venue: "Atlanta",                 kickoff_at: t(2026, 7, 7, 22, 0) },   # TODO verificar hora
  { number: 96, stage: "r16", home_label: "Ganador P85", away_label: "Ganador P87", home_source_number: 85, away_source_number: 87, venue: "Vancouver",               kickoff_at: t(2026, 7, 7, 18, 0) },   # TODO verificar hora

  # ───────── CUARTOS (QF) — ganadores de R16 ─────────
  { number: 97,  stage: "qf", home_label: "Ganador P89", away_label: "Ganador P90", home_source_number: 89, away_source_number: 90, venue: "Boston",      kickoff_at: t(2026, 7, 9, 20, 0) },    # TODO verificar hora
  { number: 98,  stage: "qf", home_label: "Ganador P93", away_label: "Ganador P94", home_source_number: 93, away_source_number: 94, venue: "Los Ángeles", kickoff_at: t(2026, 7, 10, 20, 0) },   # TODO verificar hora
  { number: 99,  stage: "qf", home_label: "Ganador P91", away_label: "Ganador P92", home_source_number: 91, away_source_number: 92, venue: "Miami",       kickoff_at: t(2026, 7, 11, 20, 0) },   # TODO verificar hora
  { number: 100, stage: "qf", home_label: "Ganador P95", away_label: "Ganador P96", home_source_number: 95, away_source_number: 96, venue: "Kansas City", kickoff_at: t(2026, 7, 11, 23, 0) },   # TODO verificar hora

  # ───────── SEMIFINALES (SF) — ganadores de QF ─────────
  { number: 101, stage: "sf", home_label: "Ganador P97", away_label: "Ganador P98",  home_source_number: 97, away_source_number: 98,  venue: "Dallas",  kickoff_at: t(2026, 7, 14, 22, 0) },  # TODO verificar hora
  { number: 102, stage: "sf", home_label: "Ganador P99", away_label: "Ganador P100", home_source_number: 99, away_source_number: 100, venue: "Atlanta", kickoff_at: t(2026, 7, 15, 22, 0) },  # TODO verificar hora

  # ───────── TERCER LUGAR — perdedores de las semis ─────────
  { number: 103, stage: "third", home_label: "Perdedor P101", away_label: "Perdedor P102",
    home_source_number: 101, away_source_number: 102, home_source_result: "loser", away_source_result: "loser",
    venue: "Miami", kickoff_at: t(2026, 7, 18, 20, 0) },  # TODO verificar hora

  # ───────── FINAL — ganadores de las semis ─────────
  { number: 104, stage: "final", home_label: "Ganador P101", away_label: "Ganador P102",
    home_source_number: 101, away_source_number: 102,
    venue: "Nueva York/Nueva Jersey", kickoff_at: t(2026, 7, 19, 19, 0) }
]

# Defaults para que los source_result no especificados sean "winner".
MATCHES.each do |attrs|
  attrs[:home_source_result] ||= "winner" if attrs[:home_source_number]
  attrs[:away_source_result] ||= "winner" if attrs[:away_source_number]
end

# Idempotente: corre seeds las veces que quieras sin duplicar.
created = 0
updated = 0

MATCHES.each do |attrs|
  match = Match.find_or_initialize_by(number: attrs[:number])
  match.new_record? ? created += 1 : updated += 1
  match.assign_attributes(attrs)
  match.status ||= "scheduled"
  match.save!
end

puts "Quiniela Mundial 2026 — eliminación directa"
puts "  Creados:      #{created}"
puts "  Actualizados: #{updated}"
puts "  Total:        #{Match.count} partidos"
puts "  Por ronda:    " + Match.group(:stage).count.to_s

# Premio por defecto (editable en el admin). Solo se pone si aún no hay uno.
tournament = Tournament.current
if tournament.prize_description.blank?
  tournament.update!(prize_description: "🍕 Pizza Party — pizzas y refrescos/cheves para ti y tus amigxs")
end

# ---------------------------------------------------------------------------
# Admin del torneo (Louie-G). Idempotente.
# Contraseña: en producción se toma de ENV["ADMIN_PASSWORD"] (no se hardcodea);
# en dev/test cae a "password". Queda inscrito para poder jugar también.
# ---------------------------------------------------------------------------
admin_email = "luismnzr@gmail.com"
admin_password = ENV["ADMIN_PASSWORD"].presence || (Rails.env.production? ? nil : "password")

admin = User.find_or_initialize_by(email: admin_email)
if admin.new_record?
  if admin_password
    admin.assign_attributes(
      first_name: "Louie", last_name: "G", display_name: "Louie-G", role: :admin,
      password: admin_password, password_confirmation: admin_password
    )
    admin.save!
    puts "Admin creado: #{admin_email}"
  else
    puts "⚠️  Define ADMIN_PASSWORD para crear el admin (#{admin_email}) en producción."
  end
else
  admin.update!(display_name: "Louie-G", role: :admin)
end

# Inscripción pagada del admin (organizador) para que también juegue.
if admin.persisted?
  entry = Entry.find_or_initialize_by(user: admin, tournament: tournament)
  entry.update!(status: :paid, amount: tournament.entry_fee, paid_at: Time.current) unless entry.paid?
end

# Jugador de demo extra — solo fuera de producción, para probar el leaderboard.
unless Rails.env.production?
  player = User.find_or_initialize_by(email: "jugador@quiniela.mx")
  player.assign_attributes(
    first_name: "Demo", last_name: "Jugador", display_name: "Demo",
    role: :student, password: "password", password_confirmation: "password"
  )
  player.save!
  demo_entry = Entry.find_or_initialize_by(user: player, tournament: tournament)
  demo_entry.update!(status: :paid, amount: tournament.entry_fee, paid_at: Time.current) unless demo_entry.paid?
  puts "Cuentas dev: #{admin_email} / password (admin) · jugador@quiniela.mx / password"
end