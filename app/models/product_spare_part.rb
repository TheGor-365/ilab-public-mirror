class ProductSparePart < ApplicationRecord
  belongs_to :product
  belongs_to :spare_part
end
