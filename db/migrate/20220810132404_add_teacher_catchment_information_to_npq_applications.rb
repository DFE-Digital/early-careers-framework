# frozen_string_literal: true

class AddTeacherCatchmentInformationToNPQApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :teacher_catchment, :text
    add_column :npq_applications, :teacher_catchment_country, :text
  end
end
