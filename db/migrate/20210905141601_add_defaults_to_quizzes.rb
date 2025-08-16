class AddDefaultsToQuizzes < ActiveRecord::Migration[6.1]
  def change
    add_column :quizzes, :passing_score,         :integer, default: 70
    add_column :quizzes, :num_questions_to_show, :integer, default: 10
  end
end
