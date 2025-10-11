FactoryBot.define do
  factory :quiz_question do
    content { "MyText" }
    quiz { nil }
  end
end
