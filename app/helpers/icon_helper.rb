# frozen_string_literal: true
module IconHelper
  # Соответствия нашим "логическим" именам -> Bootstrap Icons
  ICON_MAP = {
    "tag"      => "tag",
    "chip"     => "memory",      # про память/Storage
    "palette"  => "palette",
    "wallet"   => "wallet2",     # про цену
    "state"    => "patch-check", # про статус/состояние
    "calendar" => "calendar3",
    "hash"     => "hash"
  }.freeze

  def il_icon(name, title: nil, class_name: "")
    bi = ICON_MAP[name.to_s] || "dot"
    content_tag(:i, "", class: "bi bi-#{bi} #{class_name}", title: title, data: { bs_toggle: "tooltip" })
  end
end
