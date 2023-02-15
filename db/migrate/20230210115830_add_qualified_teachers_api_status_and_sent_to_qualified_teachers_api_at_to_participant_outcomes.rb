# frozen_string_literal: true

class AddQualifiedTeachersApiStatusAndSentToQualifiedTeachersApiAtToParticipantOutcomes < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_outcomes, :qualified_teachers_api_request_successful, :boolean
    add_column :participant_outcomes, :sent_to_qualified_teachers_api_at, :datetime
  end
end
