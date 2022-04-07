# frozen_string_literal: true

class Induction::ChangePreferredIdentity < BaseService
  def call
    # NOTE: this in not the place to change a programme or transfer a participant
    # This creates a new induction record to preserve the email address used
    # at a point in time during induction.
    # We could just update the induction_record but we'd then lose that
    # ability to track it
    ActiveRecord::Base.transaction do
      time_now = Time.zone.now
      induction_record.changing!(time_now)

      Induction::Enrol.call(participant_profile: induction_record.participant_profile,
                            induction_programme: induction_record.induction_programme,
                            start_date: time_now,
                            preferred_identity: preferred_identity)
    end
  end

private

  attr_reader :preferred_identity, :induction_record

  def initialize(induction_record:, preferred_identity:)
    @induction_record = induction_record
    @preferred_identity = preferred_identity
  end
end
