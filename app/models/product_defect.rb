class ProductDefect < ApplicationRecord
  belongs_to :product
  belongs_to :defect
end
