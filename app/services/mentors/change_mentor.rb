# frozen_string_literal: true

class Mentors::Change < BaseService
  def call
    ActiveRecord::Base.transaction do
      Induction::ChangeInductionRecord.call(induction_record:,
                                            changes: { mentor_profile: })

      induction_record.participant_profile.update!(mentor_profile:)
    end
  end

private

  attr_reader :mentor_profile, :induction_record

  def initialize(induction_record:, mentor_profile: nil)
    @induction_record = induction_record
    @mentor_profile = mentor_profile
  end
end
