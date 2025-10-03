Rails.application.config.to_prepare do
  Product.after_commit(on: :create) do
    ActiveSupport::Notifications.instrument("create.product", record: self)
  end
end
