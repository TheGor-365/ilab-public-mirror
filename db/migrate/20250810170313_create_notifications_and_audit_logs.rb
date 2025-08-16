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
