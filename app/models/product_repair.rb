class ProductRepair < ApplicationRecord
  belongs_to :product
  belongs_to :repair
end
