FactoryBot.define do
  factory :strategy do
    name { "Foo" }
    min_buy_required { 1 }
    min_sell_required { 1 }

    association :user, factory: :user
  end
end
