# frozen_string_literal: true

class DissociateWithdrawnMentorsFromInductionRecords < ActiveRecord::Migration[6.1]
  def change
    InductionRecord.joins(:mentor_profile)
                   .where(participant_profiles: { status: :withdrawn })
                   .update_all(mentor_profile_id: nil)
  end
end
