# frozen_string_literal: true

class AddUserIdAndParticipantTypeToAnalyticsECFInduction < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_inductions, :user_id, :uuid
    add_column :ecf_inductions, :participant_type, :string
  end
end
