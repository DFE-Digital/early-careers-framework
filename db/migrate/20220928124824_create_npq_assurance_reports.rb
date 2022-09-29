# frozen_string_literal: true

class CreateNPQAssuranceReports < ActiveRecord::Migration[6.1]
  def change
    create_view :npq_assurance_reports
  end
end
