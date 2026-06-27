class LeaderboardService
  Row = Struct.new(:user, :points, :correct_count, :graded_count, keyword_init: true) do
    def accuracy
      return 0.0 if graded_count.zero?

      (correct_count.to_f / graded_count * 100).round(1)
    end
  end

  class << self
    # Ranking de jugadores inscritos (Entry pagado), ordenado por puntos totales
    # y desempate por % de aciertos. En vivo vía Turbo Streams.
    def rankings(tournament = Tournament.current)
      user_ids = tournament.paid_entries.pluck(:user_id)
      return [] if user_ids.empty?

      users = User.where(id: user_ids).index_by(&:id)
      preds = Prediction.where(user_id: user_ids).includes(:match)

      rows = user_ids.map do |uid|
        mine = preds.select { |p| p.user_id == uid }
        graded = mine.select { |p| p.match.status == "finished" && p.match.advancing_team.present? }

        Row.new(
          user: users[uid],
          points: mine.sum(&:points_awarded),
          correct_count: graded.count(&:correct?),
          graded_count: graded.size
        )
      end

      rows.sort_by { |r| [ -r.points, -r.accuracy, r.user.display_name_or_default.downcase ] }
    end

    # Reusa mi patrón de broadcasts (Turbo Streams) — reemplaza la tabla del
    # leaderboard en todos los clientes suscritos al stream "leaderboard".
    def broadcast(tournament = Tournament.current)
      Turbo::StreamsChannel.broadcast_replace_to(
        "leaderboard",
        target: "leaderboard",
        partial: "leaderboard/table",
        locals: { rankings: rankings(tournament), tournament: tournament }
      )
    end
  end
end
