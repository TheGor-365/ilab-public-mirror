# frozen_string_literal: true
class OptimizeProductDetailsLookup < ActiveRecord::Migration[7.0]
  def up
    # Если Postgres — добавим функциональные индексы для быстрых LOWER-поисков
    return unless ActiveRecord::Base.connection.adapter_name.downcase.include?("postgres")

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_products_on_lower_name
        ON products (LOWER(name));
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_models_on_lower_title
        ON models (LOWER(title));
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_phones_on_lower_model_title
        ON phones (LOWER(model_title));
    SQL
  end

  def down
    return unless ActiveRecord::Base.connection.adapter_name.downcase.include?("postgres")

    execute "DROP INDEX IF EXISTS index_products_on_lower_name;"
    execute "DROP INDEX IF EXISTS index_models_on_lower_title;"
    execute "DROP INDEX IF EXISTS index_phones_on_lower_model_title;"
  end
end
