# Автосинк ссылок каталога после создания листинга, если есть sku_id
ActiveSupport::Notifications.subscribe("create.product") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  product = event.payload[:record]
  if product.is_a?(Product) && product.sku_id.present?
    CatalogSyncProductLinksJob.perform_later(product.id)
  end
end
