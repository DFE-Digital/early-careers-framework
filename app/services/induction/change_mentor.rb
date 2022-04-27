# frozen_string_literal: true

class Induction::ChangeMentor < BaseService
  def call
    Induction::ChangeInductionRecord.call(induction_record: induction_record,
                                          changes: { mentor_profile: mentor_profile })
  end

private

  attr_reader :mentor_profile, :induction_record

  def initialize(induction_record:, mentor_profile: nil)
    @induction_record = induction_record
    @mentor_profile = mentor_profile
  end
end
