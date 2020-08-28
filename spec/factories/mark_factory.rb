require_relative "../../models/mark"
require_relative "../../models/indicator"
require_relative "../../models/strategy"

FactoryBot.define do
  factory :mark do
    required { false }
    options { {} }
    limits { [] }
    fileset { }

    association :strategy, factory: :strategy
    association :indicator
  end
end
