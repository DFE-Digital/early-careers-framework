class CreateECFAssuranceReports < ActiveRecord::Migration[6.1]
  def change
    create_view :ecf_assurance_reports
  end
end
