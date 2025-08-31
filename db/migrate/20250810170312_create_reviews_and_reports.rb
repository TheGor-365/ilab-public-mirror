# frozen_string_literal: true
class CreateReviewsAndReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :product, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text    :pros
      t.text    :cons
      t.text    :body
      t.integer :state, null: false, default: 0   # pending,published,rejected
      t.datetime :moderated_at
      t.integer :violations_count, null: false, default: 0
      t.timestamps
    end
    add_index :reviews, :state

    create_table :violation_reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.string  :reportable_type, null: false
      t.bigint  :reportable_id,   null: false
      t.integer :reason, null: false, default: 0   # fraud,spam,counterfeit,offensive,other
      t.text    :details
      t.integer :state, null: false, default: 0    # open,in_review,resolved,rejected
      t.references :moderator, foreign_key: { to_table: :users }
      t.text    :resolution
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :violation_reports, %i[reportable_type reportable_id]
    add_index :violation_reports, :state
  end
end
