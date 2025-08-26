class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|
      t.references :quiz_question, null:    false, foreign_key: true
      t.references :user,          null:    false, foreign_key: true
      t.text       :content
      t.boolean    :correct,       default: false
      t.string     :avatar,        default: ''
      t.string     :images,        array:   true,  default: []
      t.string     :videos,        array:   true,  default: []

      t.timestamps
    end
  end
end
