class CreateQuizQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :quiz_questions do |t|
      t.references :quiz,    null: false, foreign_key: true
      t.text       :content
      t.string     :avatar,  default: ''
      t.string     :images,  array: true, default: []
      t.string     :videos,  array: true, default: []

      t.timestamps
    end
  end
end
