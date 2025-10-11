class AddUniqueIndexToProductsVariants < ActiveRecord::Migration[7.1]
  def change
    cols = ActiveRecord::Base.connection.columns(:products).map(&:name)

    # формируем ключ по наличию колонок
    key = %w[storage color].select { |c| cols.include?(c) }
    key << 'generation_id' if cols.include?('generation_id')
    key << 'model_id'      if cols.include?('model_id')
    key << 'phone_id'      if cols.include?('phone_id')

    if key.size >= 2 # хотя бы storage+color
      add_index :products, key.map(&:to_sym), unique: true, name: "index_products_on_variant_key"
    end
  end
end
