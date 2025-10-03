# frozen_string_literal: true
class CatalogResolver
  # Возвращает {generation:, phone:, model:} или nil
  def self.resolve(title)
    return nil if title.to_s.strip.blank?
    t = ActiveRecord::Base.sanitize_sql_like(title.to_s.strip)

    gen = Generation.where("LOWER(title) = ?", t.downcase).first ||
          Generation.where("title ILIKE ?", "%#{t}%").order(:id).first

    phone = Phone.where("LOWER(model_title) = ?", t.downcase).first ||
            Phone.where("model_title ILIKE ?", "%#{t}%").order(:id).first

    model = Model.where("LOWER(title) = ?", t.downcase).first ||
            Model.where("title ILIKE ?", "%#{t}%").order(:id).first

    gen ||= phone&.generation || model&.generation
    phone ||= model&.phone

    return nil unless gen || phone || model
    { generation: gen, phone: phone, model: model }
  end
end
