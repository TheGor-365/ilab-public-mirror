# frozen_string_literal: true
module ProductSku
  extend ActiveSupport::Concern

  included do
    # ВАЖНО:
    # - НЕ делегируем :generation к :sku, чтобы не затирать AR-ассоциацию Product#generation.
    # - belongs_to :sku определён в самой модели Product (чтобы не дублировать).

    after_commit :sync_catalog_links, on: :create
  end

  private

  def sync_catalog_links
    ProductCatalogSync.new(self, take: { repairs: 2, defects: 2, mods: 2, spare_parts: 2 }).call
  rescue => e
    Rails.logger.warn("[ProductSku] sync_catalog_links failed for product=#{id}: #{e.class} #{e.message}")
  end
end
