class MakePhoneIdNotNullInCategories < ActiveRecord::Migration[7.1]
  # В этой миграции НЕ используем "боевые" модели, чтобы не словить их валидации.
  class MCategory   < ActiveRecord::Base; self.table_name = "categories";   end
  class MPhone      < ActiveRecord::Base; self.table_name = "phones";       end
  class MGeneration < ActiveRecord::Base; self.table_name = "generations";  end

  def up
    # Если уже всё хорошо (нет NULL-ов), просто включаем NOT NULL.
    nulls_count = MCategory.where(phone_id: nil).count
    if nulls_count.zero?
      change_column_null :categories, :phone_id, false
      return
    end

    # Есть NULL-ы. В dev/test аккуратно подставим валидный "временный" phone.
    if Rails.env.development? || Rails.env.test?
      say "Backfill categories.phone_id for #{nulls_count} rows (dev/test only)…"

      # Создаём минимальную Generation (тут ещё нет полей family и т.п. — они в более поздней миграции).
      gen = MGeneration.create!(
        title:      "Temporary Generation",
        created_at: Time.current, updated_at: Time.current
      )

      # Создаём Phone с обязательным generation_id (колонка уже NOT NULL с 20211205085749).
      phone = MPhone.create!(
        model_title:  "Temporary Phone",
        generation_id: gen.id,
        created_at:   Time.current, updated_at: Time.current
      )

      # Проставляем phone_id всем категориям, где он NULL.
      MCategory.where(phone_id: nil).update_all(phone_id: phone.id)

      # Теперь можно зажать NOT NULL.
      change_column_null :categories, :phone_id, false
    else
      # В проде намеренно не делаем неявный бэкофис без согласования.
      raise ActiveRecord::IrreversibleMigration,
            "Found categories with NULL phone_id. Backfill them before enforcing NOT NULL."
    end
  end

  def down
    change_column_null :categories, :phone_id, true
  end
end
