# frozen_string_literal: true

class AddRequestForDetailsSentAtToParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_profiles, :request_for_details_sent_at, :datetime
  end
end
