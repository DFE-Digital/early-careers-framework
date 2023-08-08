# frozen_string_literal: true

class Induction::Complete < BaseService
  def call
    ActiveRecord::Base.transaction do
      participant_profile.update!(induction_completion_date: completion_date)

      Induction::ChangeInductionRecord.call(induction_record: latest_induction_record,
                                            changes: { induction_status: :completed })
    end
  end

private

  attr_reader :participant_profile, :completion_date

  def initialize(participant_profile:, completion_date:)
    @participant_profile = participant_profile
    @completion_date = completion_date
  end

  def latest_induction_record
    @latest_induction_record ||= Induction::FindBy.call(participant_profile:)
  end
end
