# frozen_string_literal: true
class CatalogSyncProductLinksJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find_by(id: product_id)
    return unless product
    CatalogSync::ProductLinks.new(product).call
  end
end
