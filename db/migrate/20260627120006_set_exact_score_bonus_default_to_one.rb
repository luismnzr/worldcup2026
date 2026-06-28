class SetExactScoreBonusDefaultToOne < ActiveRecord::Migration[7.2]
  def up
    change_column_default :tournaments, :exact_score_bonus, from: 2, to: 1
    # Baja el bonus en torneos que aún tenían el default anterior (2).
    execute "UPDATE tournaments SET exact_score_bonus = 1 WHERE exact_score_bonus = 2"
  end

  def down
    change_column_default :tournaments, :exact_score_bonus, from: 1, to: 2
    execute "UPDATE tournaments SET exact_score_bonus = 2 WHERE exact_score_bonus = 1"
  end
end
