require_relative "../../models/user"

FactoryBot.define do
  factory :user do
    name { "Foo" }
    email { "some@email.com" }
  end
end
