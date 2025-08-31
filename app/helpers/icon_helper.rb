# frozen_string_literal: true
module IconHelper
  def il_icon(name, title: nil, class_name: "")
    svg = case name.to_s
    when "tag"      # Название/модель
      '<svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path d="M20 10l-8-8H4a2 2 0 00-2 2v8l8 8 10-10zM7 7a2 2 0 114 0 2 2 0 01-4 0z" fill="currentColor"/></svg>'
    when "chip"     # Память/Storage
      '<svg viewBox="0 0 24 24" width="18" height="18"><rect x="6" y="6" width="12" height="12" rx="2" fill="currentColor"/></svg>'
    when "palette"  # Цвет/Color
      '<svg viewBox="0 0 24 24" width="18" height="18"><path d="M12 3a9 9 0 00-9 9 7 7 0 007 7h5a3 3 0 100-6h-1a1 1 0 01-1-1V9a6 6 0 00-1-3 8.9 8.9 0 00-0-.01z" fill="currentColor"/></svg>'
    when "wallet"   # Цена/Price
      '<svg viewBox="0 0 24 24" width="18" height="18"><path d="M3 7h18v10H3z" stroke="currentColor" fill="none"/><circle cx="17" cy="12" r="1.5" fill="currentColor"/></svg>'
    when "state"    # Состояние
      '<svg viewBox="0 0 24 24" width="18" height="18"><path d="M12 2l9 4v6c0 5-3.5 9.5-9 10-5.5-.5-9-5-9-10V6l9-4z" fill="currentColor"/></svg>'
    when "calendar" # Дата релиза/поколение
      '<svg viewBox="0 0 24 24" width="18" height="18"><rect x="3" y="5" width="18" height="16" rx="2" fill="none" stroke="currentColor"/><path d="M8 3v4M16 3v4" stroke="currentColor"/></svg>'
    when "hash"     # SKU/вариант
      '<svg viewBox="0 0 24 24" width="18" height="18"><path d="M10 3L6 21M18 3l-4 18M3 10h18M2 16h18" stroke="currentColor"/></svg>'
    else
      ''
    end
    content_tag(:span, svg.html_safe, class: "il-icon #{class_name}", title: title, data: {bs_toggle: "tooltip"})
  end
end
