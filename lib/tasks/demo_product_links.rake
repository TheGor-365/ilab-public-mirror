# frozen_string_literal: true
#
# Usage:
#   bin/rails demo:attach_links
#   → Для каждого товара привязывает до 2 repair/defect/mod/spare_part.
#     Сначала ищет по generation_id; если ничего не нашлось — берёт глобальные записи.

namespace :demo do
  desc "Attach some generation items to products for demo (с фолбэком на глобальные справочники)"
  task attach_links: :environment do
    Product.includes(:generation).find_each do |p|
      next unless p.generation_id

      # helpers: сначала по generation_id, если пусто — глобально
      pick_repairs = -> {
        scope = Repair.where(generation_id: p.generation_id)
        scope = Repair.all if scope.limit(2).empty?
        scope.limit(2).to_a
      }
      pick_defects = -> {
        scope = Defect.where(generation_id: p.generation_id)
        scope = Defect.all if scope.limit(2).empty?
        scope.limit(2).to_a
      }
      pick_mods = -> {
        scope = Mod.where(generation_id: p.generation_id)
        scope = Mod.all if scope.limit(2).empty?
        scope.limit(2).to_a
      }
      pick_spares = -> {
        scope = SparePart.where(generation_id: p.generation_id)
        scope = SparePart.all if scope.limit(2).empty?
        scope.limit(2).to_a
      }

      if p.respond_to?(:repairs) && p.repairs.empty?
        pick_repairs.call.each { |r| ProductRepair.find_or_create_by!(product: p, repair: r) }
      end
      if p.respond_to?(:defects) && p.defects.empty?
        pick_defects.call.each { |d| ProductDefect.find_or_create_by!(product: p, defect: d) }
      end
      if p.respond_to?(:mods) && p.mods.empty?
        pick_mods.call.each { |m| ProductMod.find_or_create_by!(product: p, mod: m) }
      end
      if p.respond_to?(:spare_parts) && p.spare_parts.empty?
        pick_spares.call.each { |s| ProductSparePart.find_or_create_by!(product: p, spare_part: s) }
      end
    end
    puts "Demo attach done"
  end
end
