class Sku < ApplicationRecord
  belongs_to :generation
  belongs_to :phone, optional: true   # временно, чтобы не потерять связь с конкретным device, если нужна
  has_many   :products, dependent: :nullify

  # Доменные знания через поколение (а у поколения - через phones)
  # Это даст s.generation.repairs / defects / mods / spare_parts если объявлены на Generation.
  delegate :repairs, :defects, :mods, :spare_parts, to: :generation, allow_nil: true

  validates :generation_id, presence: true
end
