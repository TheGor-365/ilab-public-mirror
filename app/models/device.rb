class Device < ApplicationRecord
  self.table_name = 'phones'
  belongs_to :generation
end
