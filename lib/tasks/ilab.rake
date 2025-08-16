# frozen_string_literal: true
namespace :ilab do
  namespace :debug do
    desc "Показать путь резолва товара: rake ilab:debug:product_context[ID]"
    task :product_context, [:id] => :environment do |_, args|
      id = args[:id].to_i
      p = Product.find(id)
      title = p.respond_to?(:match_title_for_catalog) ? p.match_title_for_catalog : p.name
      puts "Product##{p.id} title: #{title.inspect}"

      norm = Normalizers::AppleTitleNormalizer.call(title.to_s)
      puts "  base_label: #{norm.base_label}"
      puts "  tokens:     #{norm.tokens.join(', ')}"
      puts "  storage:    #{norm.storage_gb}, color: #{norm.color}"

      ctx = Resolvers::ProductMatcher.call(p)
      puts "  MODEL:      #{ctx.model&.id}  #{ctx.model&.try(:title)}"
      puts "  PHONE:      #{ctx.phone&.id}  #{[ctx.phone&.try(:model_title), ctx.phone&.try(:title)].compact.first}"
      puts "  GENERATION: #{ctx.generation&.id}  #{[ctx.generation&.try(:title), ctx.generation&.try(:name), ctx.generation&.try(:code)].compact.first}"
    end
  end
end
