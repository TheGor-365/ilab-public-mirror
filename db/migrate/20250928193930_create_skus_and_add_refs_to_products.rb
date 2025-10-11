class CreateSkusAndAddRefsToProducts < ActiveRecord::Migration[7.1]
  def fk_exists?(from_table, to_table, column:)
    connection.foreign_keys(from_table).any? do |fk|
      fk.to_table.to_s == to_table.to_s &&
        (
          (fk.respond_to?(:column) && fk.column.to_s == column.to_s) ||
          (fk.respond_to?(:options) && fk.options[:column].to_s == column.to_s)
        )
    end
  end

  def up
    create_table :skus do |t|
      t.references :generation, null: false, foreign_key: true
      t.references :phone, null: true, foreign_key: { to_table: :phones } # временно
      t.string :storage
      t.string :color
      t.timestamps
    end

    add_index :skus, [:generation_id, :storage, :color], name: "idx_skus_generation_storage_color"
    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS ux_skus_generation_storage_color
      ON skus (
        generation_id,
        COALESCE(LOWER(storage), ''),
        COALESCE(LOWER(color),   '')
      );
    SQL

    # products.sku_id — новый
    add_column :products, :sku_id, :bigint, null: true unless column_exists?(:products, :sku_id)
    add_index  :products, :sku_id unless index_exists?(:products, :sku_id)
    add_foreign_key :products, :skus, column: :sku_id, on_delete: :nullify unless fk_exists?(:products, :skus, column: :sku_id)

    # products.seller_id — уже существует в базе → добавляем только недостающее
    unless column_exists?(:products, :seller_id)
      add_column :products, :seller_id, :bigint, null: true
    end
    add_index :products, :seller_id unless index_exists?(:products, :seller_id)
    if ActiveRecord::Base.connection.table_exists?(:users) && !fk_exists?(:products, :users, column: :seller_id)
      add_foreign_key :products, :users, column: :seller_id, on_delete: :nullify
    end

    # -----------------------
    # БЭКФИЛЛ SKU из существующих products (по generation_id, storage, color)
    # -----------------------
    execute <<~SQL
      INSERT INTO skus (generation_id, phone_id, storage, color, created_at, updated_at)
      SELECT DISTINCT p.generation_id,
             p.phone_id,
             NULLIF(BTRIM(p.storage), ''),
             NULLIF(BTRIM(p.color),   ''),
             NOW(), NOW()
      FROM products p
      LEFT JOIN skus s
        ON s.generation_id = p.generation_id
       AND COALESCE(LOWER(s.storage),'') = COALESCE(LOWER(NULLIF(BTRIM(p.storage), '')),'')
       AND COALESCE(LOWER(s.color),  '') = COALESCE(LOWER(NULLIF(BTRIM(p.color),   '')),'')
      WHERE s.id IS NULL
        AND p.generation_id IS NOT NULL;
    SQL

    execute <<~SQL
      UPDATE products p
         SET sku_id = s.id
      FROM skus s
      WHERE p.generation_id = s.generation_id
        AND COALESCE(LOWER(NULLIF(BTRIM(p.storage), '')),'') = COALESCE(LOWER(s.storage),'')
        AND COALESCE(LOWER(NULLIF(BTRIM(p.color),   '')),'') = COALESCE(LOWER(s.color),'')
        AND (p.sku_id IS DISTINCT FROM s.id);
    SQL
  end

  def down
    remove_foreign_key :products, column: :sku_id rescue nil
    remove_foreign_key :products, column: :seller_id rescue nil
    remove_index  :products, :seller_id rescue nil
    remove_index  :products, :sku_id    rescue nil
    remove_column :products, :seller_id if column_exists?(:products, :seller_id)
    remove_column :products, :sku_id    if column_exists?(:products, :sku_id)

    execute "DROP INDEX IF EXISTS ux_skus_generation_storage_color;"
    remove_index :skus, name: "idx_skus_generation_storage_color" rescue nil
    drop_table :skus
  end
end
