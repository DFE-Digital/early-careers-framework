# frozen_string_literal: true

class DissociateWithdrawnMentorsFromInductionRecords < ActiveRecord::Migration[6.1]
  def change
    InductionRecord.current
                   .joins(:mentor_profile)
                   .where(participant_profiles: { status: :withdrawn })
                   .find_each do |induction_record|
      Induction::ChangeMentor.call(induction_record:)
    end
  end
end
