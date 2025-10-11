module ProductSidebarHelper
  def sidebar_entry_path_for(kind, entity_id)
    case kind
    when "repair"     then repair_path(entity_id)
    when "defect"     then defect_path(entity_id)
    when "mod"        then mod_path(entity_id)
    when "spare_part" then spare_part_path(entity_id)
    else "#"
    end
  end

  def sidebar_entry_icon(kind)
    {
      "repair"     => "bi-tools",
      "defect"     => "bi-bug",
      "mod"        => "bi-puzzle",
      "spare_part" => "bi-cpu"
    }[kind] || "bi-dot"
  end
end
