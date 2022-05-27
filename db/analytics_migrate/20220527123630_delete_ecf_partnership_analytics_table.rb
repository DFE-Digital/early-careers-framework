# frozen_string_literal: true

class DeleteECFPartnershipAnalyticsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :ecf_partnership_analytics
  end
end
