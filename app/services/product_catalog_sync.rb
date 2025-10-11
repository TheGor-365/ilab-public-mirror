class ProductCatalogSync
  DEFAULT_TAKE = { repairs: 2, defects: 2, mods: 2, spare_parts: 2 }.freeze

  def initialize(product, take: {})
    @product = product
    @take    = DEFAULT_TAKE.merge(take || {})
  end

  def call
    return unless @product

    # 1) берём доменные знания через поколение каталога
    gen = @product.try(:generation) || @product.try(:sku)&.generation || @product.generation
    return unless gen

    attach_repairs_from(gen)
    attach_defects_from(gen)
    attach_mods_from(gen)         # если у Generation есть mods
    attach_spare_parts_from(gen)  # если у Generation есть spare_parts
  end

  private

  def attach_repairs_from(gen)
    repairs = Array(gen.try(:repairs)).first(@take[:repairs].to_i)
    repairs.each do |r|
      @product.product_repairs.find_or_create_by!(repair_id: r.id)
    end
  rescue => e
    Rails.logger.warn("[ProductCatalogSync] attach_repairs_from: #{e.class} #{e.message}")
  end

  def attach_defects_from(gen)
    defects = Array(gen.try(:defects)).first(@take[:defects].to_i)
    defects.each do |d|
      @product.product_defects.find_or_create_by!(defect_id: d.id)
    end
  rescue => e
    Rails.logger.warn("[ProductCatalogSync] attach_defects_from: #{e.class} #{e.message}")
  end

  def attach_mods_from(gen)
    mods = Array(gen.try(:mods)).first(@take[:mods].to_i)
    mods.each do |m|
      @product.product_mods.find_or_create_by!(mod_id: m.id)
    end
  rescue => e
    Rails.logger.warn("[ProductCatalogSync] attach_mods_from: #{e.class} #{e.message}")
  end

  def attach_spare_parts_from(gen)
    spares = Array(gen.try(:spare_parts)).first(@take[:spare_parts].to_i)
    spares.each do |s|
      @product.product_spare_parts.find_or_create_by!(spare_part_id: s.id)
    end
  rescue => e
    Rails.logger.warn("[ProductCatalogSync] attach_spare_parts_from: #{e.class} #{e.message}")
  end
end
