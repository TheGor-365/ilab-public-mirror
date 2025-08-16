# frozen_string_literal: true
class AddCatalogFieldsToGenerationsAndProducts < ActiveRecord::Migration[7.1]
  def up
    # --- GENERATIONS ---
    add_column :generations, :family, :string unless column_exists?(:generations, :family)
    add_column :generations, :released_on, :date unless column_exists?(:generations, :released_on)
    add_column :generations, :discontinued_on, :date unless column_exists?(:generations, :discontinued_on)

    if ActiveRecord::Base.connection.adapter_name =~ /postg/i
      add_column :generations, :aliases, :text, array: true, default: [] unless column_exists?(:generations, :aliases)
      add_column :generations, :storage_options, :text, array: true, default: [] unless column_exists?(:generations, :storage_options)
      add_column :generations, :color_options, :text, array: true, default: [] unless column_exists?(:generations, :color_options)

      add_index :generations, :title, unique: true unless index_exists?(:generations, :title, unique: true)
      add_index :generations, :family unless index_exists?(:generations, :family)

      enable_extension 'pg_trgm' rescue nil
      begin
        execute 'CREATE INDEX index_generations_on_aliases_gin ON generations USING gin (aliases);'
      rescue
        # already exists or not supported
      end
    else
      add_column :generations, :aliases, :text unless column_exists?(:generations, :aliases)
      add_column :generations, :storage_options, :text unless column_exists?(:generations, :storage_options)
      add_column :generations, :color_options, :text unless column_exists?(:generations, :color_options)
      add_index :generations, :title, unique: true unless index_exists?(:generations, :title, unique: true)
      add_index :generations, :family unless index_exists?(:generations, :family)
    end

    # --- PRODUCTS ---
    add_column :products, :storage, :string unless column_exists?(:products, :storage)
    add_column :products, :color, :string unless column_exists?(:products, :color)

    # добавить products.model_id, если его нет
    unless column_exists?(:products, :model_id)
      add_reference :products, :model, foreign_key: true, index: true
    else
      add_index :products, :model_id unless index_exists?(:products, :model_id)
    end

    add_index :products, :generation_id unless index_exists?(:products, :generation_id)
    add_index :products, :phone_id unless index_exists?(:products, :phone_id)
  end

  def down
    # --- PRODUCTS ---
    if column_exists?(:products, :model_id)
      remove_foreign_key :products, :models rescue nil
      remove_index :products, :model_id if index_exists?(:products, :model_id)
      remove_column :products, :model_id
    end
    remove_index :products, :generation_id if index_exists?(:products, :generation_id)
    remove_index :products, :phone_id if index_exists?(:products, :phone_id)
    remove_column :products, :storage if column_exists?(:products, :storage)
    remove_column :products, :color if column_exists?(:products, :color)

    # --- GENERATIONS ---
    begin
      execute 'DROP INDEX IF EXISTS index_generations_on_aliases_gin;'
    rescue; end
    remove_index :generations, :title if index_exists?(:generations, :title)
    remove_index :generations, :family if index_exists?(:generations, :family)
    remove_column :generations, :family if column_exists?(:generations, :family)
    remove_column :generations, :released_on if column_exists?(:generations, :released_on)
    remove_column :generations, :discontinued_on if column_exists?(:generations, :discontinued_on)
    remove_column :generations, :aliases if column_exists?(:generations, :aliases)
    remove_column :generations, :storage_options if column_exists?(:generations, :storage_options)
    remove_column :generations, :color_options if column_exists?(:generations, :color_options)
  end
end
