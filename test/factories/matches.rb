FactoryBot.define do
  factory :match do
    sequence(:number) { |n| 1000 + n }
    stage { "r32" }
    home_label { "1A" }
    away_label { "2B" }
    status { "scheduled" }
    kickoff_at { 2.days.from_now }

    # Equipos cargados y kickoff en el futuro => abierto para predicción.
    trait :open do
      home_team { "México" }
      away_team { "Argentina" }
      kickoff_at { 2.days.from_now }
    end

    # Equipos cargados pero ya pasó el kickoff => bloqueado.
    trait :locked do
      home_team { "México" }
      away_team { "Argentina" }
      kickoff_at { 2.hours.ago }
    end

    trait :finished do
      home_team { "México" }
      away_team { "Argentina" }
      kickoff_at { 2.hours.ago }
      home_score { 2 }
      away_score { 1 }
      advancing_team { "México" }
      status { "finished" }
    end
  end
end
