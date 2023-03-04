# frozen_string_literal: true

class AddUrnsArrayToPartnershipCsvUpload < ActiveRecord::Migration[6.1]
  def change
    add_column :partnership_csv_uploads, :uploaded_urns, :string, array: true
  end
end
