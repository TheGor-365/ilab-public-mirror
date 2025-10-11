class Answer < ApplicationRecord

  belongs_to :quiz_question
  belongs_to :user

end
