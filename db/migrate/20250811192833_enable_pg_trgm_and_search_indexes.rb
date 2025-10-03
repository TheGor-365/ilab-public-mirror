# frozen_string_literal: true
class EnablePgTrgmAndSearchIndexes < ActiveRecord::Migration[7.0]
  def up
    return unless ActiveRecord::Base.connection.adapter_name.downcase.include?("postgres")
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

    execute "CREATE INDEX IF NOT EXISTS idx_models_title_trgm ON models USING gin (title gin_trgm_ops);" if column_exists?(:models, :title)
    execute "CREATE INDEX IF NOT EXISTS idx_phones_model_title_trgm ON phones USING gin (model_title gin_trgm_ops);" if column_exists?(:phones, :model_title)
    %i[title name code].each do |c|
      next unless column_exists?(:generations, c)
      execute "CREATE INDEX IF NOT EXISTS idx_generations_#{c}_trgm ON generations USING gin (#{c} gin_trgm_ops);"
    end
  end

  def down
    return unless ActiveRecord::Base.connection.adapter_name.downcase.include?("postgres")
    execute "DROP INDEX IF EXISTS idx_models_title_trgm;"
    execute "DROP INDEX IF EXISTS idx_phones_model_title_trgm;"
    %i[title name code].each do |c|
      execute "DROP INDEX IF EXISTS idx_generations_#{c}_trgm;"
    end
  end
end
