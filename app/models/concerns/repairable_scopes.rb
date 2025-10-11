module RepairableScopes
  extend ActiveSupport::Concern

  included do
    belongs_to :repairable, polymorphic: true, optional: true

    scope :for, ->(obj) do
      where(repairable: obj)
    end

    def attach_repairable!(obj)
      update!(repairable: obj)
    end
  end
end
