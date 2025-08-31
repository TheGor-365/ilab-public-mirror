# frozen_string_literal: true
class CreateRepairModule < ActiveRecord::Migration[7.0]
  def change
    create_table :master_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :headline
      t.text    :skills
      t.integer :experience_years
      t.integer :hourly_rate_cents, null: false, default: 0
      t.decimal :rating_avg, precision: 4, scale: 2, null: false, default: 0
      t.integer :reviews_count, null: false, default: 0
      t.integer :certifications_count, null: false, default: 0
      t.integer :portfolio_items_count, null: false, default: 0
      t.datetime :verified_at
      t.timestamps
    end

    create_table :repair_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category,    null: false, foreign_key: true
      t.references :phone,       foreign_key: true
      t.references :generation,  foreign_key: true
      t.integer :kind,   null: false, default: 0      # 0:repair,1:tuning
      t.string  :title,  null: false
      t.text    :description
      t.integer :budget_cents
      t.string  :currency, null: false, default: 'RUB'
      t.integer :urgency, null: false, default: 1     # low,normal,high,asap
      t.integer :state,   null: false, default: 0     # open..completed,canceled
      t.jsonb   :location_json, null: false, default: {}
      t.integer :attachments_count, null: false, default: 0
      t.timestamps
    end
    add_index :repair_requests, :state
    add_index :repair_requests, :kind

    create_table :repair_bids do |t|
      t.references :repair_request, null: false, foreign_key: true
      t.references :master, null: false, foreign_key: { to_table: :users }
      t.integer :price_cents
      t.integer :estimate_days
      t.text    :message
      t.integer :state, null: false, default: 0  # offered,accepted,rejected,withdrawn
      t.timestamps
    end
    add_index :repair_bids, :state

    create_table :repair_jobs do |t|
      t.references :repair_request, null: false, foreign_key: true
      t.references :master, null: false, foreign_key: { to_table: :users }
      t.integer :state, null: false, default: 0  # assigned..done,canceled
      t.integer :progress_pct, null: false, default: 0
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end
    add_index :repair_jobs, :state

    create_table :job_events do |t|
      t.references :repair_job, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0   # status,message,photo,file,payment,delivery
      t.jsonb   :payload, null: false, default: {}
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :job_events, :occurred_at

    create_table :invoices do |t|
      t.references :repair_job, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string  :currency, null: false, default: 'RUB'
      t.integer :status, null: false, default: 0   # draft,sent,paid,canceled
      t.date    :due_on
      t.datetime :paid_at
      t.timestamps
    end
    add_index :invoices, :status
  end
end
