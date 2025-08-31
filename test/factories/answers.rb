FactoryBot.define do
  factory :answer do
    question { nil }
    content { "MyText" }
    correct { false }
  end
end
