# script/gen_ilab_migrations.rb
# Запуск: bin/rails runner script/gen_ilab_migrations.rb
# Что делает: создаёт 11 миграций в db/migrate с уже заполненным контентом.

require "fileutils"
require "active_support/inflector"

FileUtils.mkdir_p("db/migrate")

def write_migration(class_name, body, ts)
  fname = "db/migrate/#{ts}_#{class_name.underscore}.rb"
  File.write(fname, body)
  puts "✅ created: #{fname}"
end

base_time = Time.now.utc
tick = 0
next_ts = -> { (base_time + (tick += 1)).strftime("%Y%m%d%H%M%S") }

# === 1) HardenProductsForMarketplace
write_migration("HardenProductsForMarketplace", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class HardenProductsForMarketplace < ActiveRecord::Migration[7.0]
    def change
      change_table :products, bulk: true do |t|
        t.integer :condition, null: false, default: 1    # 0:new,1:used,2:for_parts,3:refurbished
        t.integer :state,     null: false, default: 0    # 0:draft,1:active,2:paused,3:sold,4:archived
        t.integer :stock,     null: false, default: 1
        t.string  :currency,  null: false, default: 'RUB'
        t.jsonb   :location_json, null: false, default: {}
        t.boolean :featured, null: false, default: false
        t.integer :violations_count, null: false, default: 0
      end
      add_index :products, :state
      add_index :products, :condition
      add_index :products, :price
    end
  end
RUBY

# === 2) CreateCartsAndItems
write_migration("CreateCartsAndItems", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class CreateCartsAndItems < ActiveRecord::Migration[7.0]
    def change
      create_table :carts do |t|
        t.references :user, foreign_key: true
        t.string  :session_id
        t.integer :items_count, null: false, default: 0
        t.decimal :total, precision: 12, scale: 2, null: false, default: 0
        t.string  :currency, null: false, default: 'RUB'
        t.timestamps
      end
      add_index :carts, :session_id, unique: true

      create_table :cart_items do |t|
        t.references :cart,    null: false, foreign_key: true
        t.references :product, null: false, foreign_key: true
        t.integer :quantity, null: false, default: 1
        t.decimal :unit_price, precision: 12, scale: 2, null: false, default: 0
        t.decimal :total,      precision: 12, scale: 2, null: false, default: 0
        t.string  :currency, null: false, default: 'RUB'
        t.timestamps
      end
      add_index :cart_items, %i[cart_id product_id], unique: true
    end
  end
RUBY

# === 3) CreateAddresses
write_migration("CreateAddresses", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class CreateAddresses < ActiveRecord::Migration[7.0]
    def change
      create_table :addresses do |t|
        t.references :user, null: false, foreign_key: true
        t.integer :kind, null: false, default: 0   # 0:shipping,1:billing
        t.string  :country_code, null: false
        t.string  :city, null: false
        t.string  :line1, null: false
        t.string  :line2
        t.string  :postal_code
        t.string  :phone
        t.string  :contact_name
        t.boolean :is_default, null: false, default: false
        t.timestamps
      end
    end
  end
RUBY

# === 4) ExtendOrders
write_migration("ExtendOrders", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class ExtendOrders < ActiveRecord::Migration[7.0]
    def change
      change_table :orders, bulk: true do |t|
        t.references :user,   foreign_key: true
        t.references :seller, foreign_key: { to_table: :users }
        t.string  :number
        t.integer :state, null: false, default: 0 # pending..refunded
        t.decimal :delivery, precision: 12, scale: 2, null: false, default: 0
        t.decimal :fee,      precision: 12, scale: 2, null: false, default: 0
        t.string  :currency, null: false, default: 'RUB'
        t.integer :payment_method
        t.references :shipping_address, foreign_key: { to_table: :addresses }
        t.references :billing_address,  foreign_key: { to_table: :addresses }
        t.datetime :paid_at
        t.datetime :canceled_at
        t.string   :reason
        t.jsonb    :metadata, null: false, default: {}
      end
      add_index :orders, :number, unique: true
      add_index :orders, :state
      add_index :orders, :paid_at
    end
  end
RUBY

# === 5) ExtendOrderItems
write_migration("ExtendOrderItems", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class ExtendOrderItems < ActiveRecord::Migration[7.0]
    def change
      change_table :order_items, bulk: true do |t|
        t.string :currency, null: false, default: 'RUB'
        t.string :title_snapshot
        t.jsonb  :meta, null: false, default: {}
      end
    end
  end
RUBY

# === 6) CreatePayments
write_migration("CreatePayments", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class CreatePayments < ActiveRecord::Migration[7.0]
    def change
      create_table :payments do |t|
        t.references :order, null: false, foreign_key: true
        t.integer :provider, null: false, default: 0 # stripe,yookassa,cloudpayments,paypal
        t.string  :provider_payment_id
        t.decimal :amount, precision: 12, scale: 2, null: false
        t.string  :currency, null: false, default: 'RUB'
        t.integer :status, null: false, default: 0   # created,authorized,captured,canceled,refunded,failed
        t.string  :error_code
        t.jsonb   :payload, null: false, default: {}
        t.datetime :paid_at
        t.timestamps
      end
      add_index :payments, %i[provider provider_payment_id], unique: true
      add_index :payments, :status
    end
  end
RUBY

# === 7) CreateShipments
write_migration("CreateShipments", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class CreateShipments < ActiveRecord::Migration[7.0]
    def change
      create_table :shipments do |t|
        t.references :order, null: false, foreign_key: true
        t.string  :tracking_number
        t.string  :carrier
        t.integer :status, null: false, default: 0  # preparing..delivered/problem
        t.jsonb   :payload, null: false, default: {}
        t.datetime :shipped_at
        t.datetime :delivered_at
        t.timestamps
      end
      add_index :shipments, :tracking_number
    end
  end
RUBY

# === 8) CreateReviewsAndReports
write_migration("CreateReviewsAndReports", <<~RUBY, next_ts.call)
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
RUBY

# === 9) CreateNotificationsAndAuditLogs
write_migration("CreateNotificationsAndAuditLogs", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class CreateNotificationsAndAuditLogs < ActiveRecord::Migration[7.0]
    def change
      create_table :notifications do |t|
        t.references :user, null: false, foreign_key: true
        t.string  :notifiable_type
        t.bigint  :notifiable_id
        t.integer :channel, null: false, default: 0  # web,email,push,telegram
        t.string  :kind
        t.jsonb   :payload, null: false, default: {}
        t.datetime :read_at
        t.datetime :sent_at
        t.timestamps
      end
      add_index :notifications, %i[notifiable_type notifiable_id]
      add_index :notifications, :read_at

      create_table :audit_logs do |t|
        t.references :actor, null: false, foreign_key: { to_table: :users }
        t.string  :action, null: false
        t.string  :subject_type, null: false
        t.bigint  :subject_id,   null: false
        t.jsonb   :metadata, null: false, default: {}
        t.timestamps
      end
      add_index :audit_logs, %i[subject_type subject_id]
      add_index :audit_logs, :created_at
    end
  end
RUBY

# === 10) CreateRepairModule
write_migration("CreateRepairModule", <<~RUBY, next_ts.call)
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
RUBY

# === 11) CreateFinanceModule
write_migration("CreateFinanceModule", <<~RUBY, next_ts.call)
  # frozen_string_literal: true
  class CreateFinanceModule < ActiveRecord::Migration[7.0]
    def change
      create_table :subscription_plans do |t|
        t.string  :name, null: false
        t.string  :slug, null: false
        t.integer :price_cents, null: false, default: 0
        t.integer :interval, null: false, default: 0 # month/year
        t.jsonb   :features, null: false, default: {}
        t.boolean :active, null: false, default: true
        t.timestamps
      end
      add_index :subscription_plans, :slug, unique: true
      add_index :subscription_plans, :active

      create_table :subscriptions do |t|
        t.references :user, null: false, foreign_key: true
        t.references :subscription_plan, null: false, foreign_key: true
        t.integer :state, null: false, default: 0 # active,past_due,canceled
        t.datetime :current_period_end, null: false
        t.timestamps
      end
      add_index :subscriptions, :state

      create_table :commissions do |t|
        t.string  :name, null: false
        t.decimal :percent, precision: 6, scale: 3, null: false, default: 0
        t.integer :applies_to, null: false, default: 0 # order,subscription,boost
        t.boolean :active, null: false, default: true
        t.timestamps
      end
      add_index :commissions, :active

      create_table :payouts do |t|
        t.references :user, null: false, foreign_key: true
        t.integer :amount_cents, null: false
        t.string  :currency, null: false, default: 'RUB'
        t.integer :state, null: false, default: 0 # pending,paid,failed
        t.string  :provider
        t.jsonb   :payload, null: false, default: {}
        t.timestamps
      end
      add_index :payouts, :state
    end
  end
RUBY

puts "\n🎯 Done. Миграции созданы. Теперь запусти: bin/rails db:migrate"
