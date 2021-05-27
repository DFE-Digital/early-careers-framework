# frozen_string_literal: true

class AddCohortIdToPartnershipCsvUploads < ActiveRecord::Migration[6.1]
  class Cohort < ActiveRecord::Base; end # rubocop:disable Rails/ApplicationRecord

  def change
    default = Cohort.find_by(start_year: 2021).id

    add_reference :partnership_csv_uploads, :cohort, index: true, default: default
    change_column_default :partnership_csv_uploads, :cohort_id, from: default, to: nil
  end
end
