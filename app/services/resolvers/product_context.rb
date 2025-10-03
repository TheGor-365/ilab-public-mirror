# frozen_string_literal: true
# Резолвит контекст товара: model, phone, generation надёжно и быстро
module Resolvers
  class ProductContext
    Result = Struct.new(:product, :model, :phone, :generation, keyword_init: true)

    class << self
      def call(product)
        # 1) Прямые связи (если есть)
        model = try_fk_model(product)
        phone = try_fk_phone(product, model)
        gen   = try_fk_generation(product, model, phone)

        # 2) По названию (точное совпадение LOWER)
        if model.nil?
          model = Model.find_by("LOWER(title) = ?", safe(product.name))
          phone ||= model&.phone
          gen   ||= model&.generation || phone&.generation
        end

        # 3) Фолбэк: искать по phone.model_title
        if phone.nil?
          phone = Phone.find_by("LOWER(model_title) = ?", safe(product.name))
          gen ||= phone&.generation
        end

        # 4) Мягкий фолбэк: ILIKE (может вернуть лишнее — используем LIMIT 1)
        if model.nil? && product.name.present?
          model ||= Model.where("title ILIKE ?", like(product.name)).order(:id).limit(1).first
          phone ||= model&.phone
          gen   ||= model&.generation || phone&.generation
        end

        Result.new(product: product, model: model, phone: phone, generation: gen)
      end

      private

      def safe(value)
        value.to_s.downcase.strip
      end

      def like(value)
        "%#{value.to_s.strip.gsub('%', '')}%"
      end

      def try_fk_model(product)
        product.respond_to?(:model) ? product.model : nil
      end

      def try_fk_phone(product, model)
        return product.phone if product.respond_to?(:phone) && product.phone.present?
        model&.phone
      end

      def try_fk_generation(product, model, phone)
        return product.generation if product.respond_to?(:generation) && product.generation.present?
        model&.generation || phone&.generation
      end
    end
  end
end
