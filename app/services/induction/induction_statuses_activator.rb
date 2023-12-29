# frozen_string_literal: true

class Induction::InductionStatusesActivator < BaseService
  def call
    ActiveRecord::Base.transaction do
      update_the_induction_record if induction_record_needs_correction?
      update_the_participant_profile if profile_needs_correction?
    end
  end

private

  attr_reader :participant_profile, :induction_record

  def initialize(participant_profile:)
    @participant_profile = participant_profile
    @induction_record = Induction::FindBy.new(participant_profile:).call
  end

  def update_the_participant_profile
    participant_profile.update(status: :active)
  end

  def update_the_induction_record
    Induction::ChangeInductionRecord.call(
      induction_record:,
      changes: { induction_status: :active },
    )
  end

  def induction_record_needs_correction?
    %w[withdrawn leaving].include?(induction_record&.induction_status)
  end

  def profile_needs_correction?
    %w[withdrawn].include?(participant_profile.status)
  end
end
