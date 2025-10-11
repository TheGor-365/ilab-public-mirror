# db/seeds/support/validate.rb
module SeedValidate
  module_function

  EXPECTED_KEYS = {
    "Defect" => %i[
      generation_id phone_id repair_id mod_id
      title description avatar modules images videos
    ],
    "Repair" => %i[
      generation_id phone_id defect_id mod_id
      title description overview avatar spare_parts images videos price
    ],
    "Mod" => %i[
      generation_id phone_id model_id defect_id repair_id
      name avatar manufacturers images videos
    ],
    "SparePart" => %i[
      generation_id phone_id mod_id
      name manufacturer avatar images videos
    ]
  }

  def warn_unknown_keys(model_name, rows)
    allowed = EXPECTED_KEYS.fetch(model_name) { [] }
    rows.each_with_index do |row, idx|
      unknown = row.keys.map(&:to_sym) - allowed
      next if unknown.empty?
      puts "[seeds][WARN] #{model_name} row##{idx + 1} unknown keys: #{unknown.inspect}"
    end
  end
end
