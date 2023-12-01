class AddEstablishmentTypesToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :establishment_type_code, :text
    add_column :schools, :establishment_type_name, :text
  end
end
