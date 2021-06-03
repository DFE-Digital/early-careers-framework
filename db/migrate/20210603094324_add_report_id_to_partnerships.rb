# frozen_string_literal: true

class AddReportIdToPartnerships < ActiveRecord::Migration[6.1]
  def change
    add_column :partnerships, :report_id, :uuid
  end
end
