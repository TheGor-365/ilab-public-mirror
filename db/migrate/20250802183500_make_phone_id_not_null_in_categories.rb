class MakePhoneIdNotNullInCategories < ActiveRecord::Migration[7.1]
  def up
    dummy_phone = Phone.find_or_create_by!(model_title: "unknown") do |p|
      p.generation_id = Generation.first&.id
    end

    Category.where(phone_id: nil).find_each do |category|
      phone = Phone.find_by(model_title: category.heading)
      category.update(phone_id: phone&.id || dummy_phone.id)
    end
    change_column_null :categories, :phone_id, false
  end

  def down
    change_column_null :categories, :phone_id, true
  end
end
