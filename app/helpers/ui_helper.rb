# frozen_string_literal: true
module UiHelper
  # Возвращает первую непустую подпись из списка attrs.
  # Не падает, если у объекта нет такого метода.
  def smart_label(record, *attrs)
    return "—" if record.nil?
    attrs.each do |attr|
      if record.respond_to?(attr)
        val = record.public_send(attr)
        return val if val.present?
      end
    end
    # последний шанс — класс и id
    record.respond_to?(:id) ? "#{record.class.name} ##{record.id}" : "—"
  end
end
