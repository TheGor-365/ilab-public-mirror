class ProductSidebarEntry < ApplicationRecord
  self.table_name  = "product_sidebar_entries"
  self.primary_key = nil

  belongs_to :product

  enum :kind,
       {
         repair:     "repair",
         defect:     "defect",
         mod:        "mod",
         spare_part: "spare_part"
       },
       prefix: true

  # Это представление — делаем запись только для чтения
  def readonly? = true

  # Защита от случайных save/destroy
  def delete     = raise ActiveRecord::ReadOnlyRecord
  def destroy(*) = raise ActiveRecord::ReadOnlyRecord
end
