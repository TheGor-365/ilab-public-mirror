# frozen_string_literal: true

module ProductsHelper
  # Аватар товара с фолбэком
  def product_avatar(product, width, height)
    avatar_path = product.avatar.present? ? product.avatar.url : 'default_product_avatar.jpg'
    image_tag(avatar_path, width: width, height: height, class: 'rounded')
  end

  # Безопасно получить ассоциацию как коллекцию (или пустой массив)
  # Не полагаемся на respond_to? — сначала проверяем рефлексию ассоциации,
  # чтобы не словить AR-ошибки при "сквозных" связях.
  def safe_assoc(obj, name)
    return [] unless obj.present?

    refl = obj.class.reflect_on_association(name)
    return [] unless refl

    obj.public_send(name)
  rescue StandardError => e
    Rails.logger.debug("[safe_assoc] #{obj.class}##{name}: #{e.class}: #{e.message}")
    []
  end

  # Количество элементов ассоциации, если она существует. Иначе 0.
  def safe_assoc_count(obj, name)
    coll = safe_assoc(obj, name)
    coll.respond_to?(:count) ? coll.count : Array(coll).size
  rescue StandardError
    0
  end

  # Короткая сводка произвольной коллекции
  # collection — Relation или Array; label — подпись; limit — сколько названий показать
  def summarize_collection(collection, label:, limit: 3)
    rel = collection.is_a?(ActiveRecord::Relation) ? collection : Array(collection)

    total =
      begin
        rel.respond_to?(:count) ? rel.count : rel.size
      rescue StandardError
        rel.size
      end

    titles =
      begin
        if rel.is_a?(ActiveRecord::Relation)
          rel.limit(limit).pluck(:title)
        else
          rel.first(limit).map { |r| try_title(r) }
        end
      rescue StandardError
        Array(rel).first(limit).map { |r| try_title(r) }
      end

    short = Array(titles).map { |t| t.to_s.truncate(24) }.join(", ")

    content_tag(:div, class: "pd-chipline") do
      safe_join(
        [
          content_tag(:span, label.to_s, class: "pd-chipline__label"),
          content_tag(:span, total.to_i, class: "pd-chipline__badge"),
          (short.present? ? content_tag(:span, short, class: "pd-chipline__items") : nil)
        ].compact,
        " "
      )
    end
  end

  private

  def try_title(record)
    return "" unless record
    record.try(:title) || record.try(:name) || record.try(:to_s) || ""
  end
end
