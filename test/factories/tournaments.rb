FactoryBot.define do
  factory :tournament do
    name { "FIFA World Cup 2026" }
    entry_fee { 50 }
    currency { "MXN" }
    prize_description { "Trofeo de campeón; el último lugar paga los tacos." }
    exact_score_bonus { 1 }
  end
end
