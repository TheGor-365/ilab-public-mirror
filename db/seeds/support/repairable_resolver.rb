module RepairableResolver
  module_function

  def resolve!(row)
    if row[:device].is_a?(Hash)
      type = row[:device][:type].to_s
      id   = row[:device][:id]
      return row.merge(repairable_type: type, repairable_id: id)
    end

    if row[:catalog].is_a?(Hash)
      fam  = row[:catalog][:family].to_s
      gttl = row[:catalog][:generation_title].to_s
      mttl = row[:catalog][:model_title].presence || gttl

      gen = Generation.by_family(fam).find_by!(title: gttl)
      ph  = Phone.find_by(model_title: mttl, generation_id: gen.id) || gen.try(:phone)

      return row.merge(repairable_type: 'Phone', repairable_id: ph.id) if ph
      raise "RepairableResolver: device not found for #{row[:catalog].inspect}"
    end

    if row[:phone_id].present?
      return row.merge(repairable_type: 'Phone', repairable_id: row[:phone_id])
    end

    row
  end
end
