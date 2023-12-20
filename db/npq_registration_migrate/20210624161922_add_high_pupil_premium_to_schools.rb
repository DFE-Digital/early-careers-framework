class AddHighPupilPremiumToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :high_pupil_premium, :boolean, null: false, default: false
  end
end
