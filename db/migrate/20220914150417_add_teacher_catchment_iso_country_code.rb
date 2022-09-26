# frozen_string_literal: true

class AddTeacherCatchmentIsoCountryCode < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :teacher_catchment_iso_country_code, :string, limit: 3
  end
end
