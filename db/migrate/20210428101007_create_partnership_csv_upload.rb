# frozen_string_literal: true

class CreatePartnershipCsvUpload < ActiveRecord::Migration[6.1]
  def change
    create_table :partnership_csv_uploads do |t|
      t.belongs_to :lead_provider
      t.timestamps
    end
  end
end
