# frozen_string_literal: true

class Induction::ChangeProgramme < BaseService
  def call
    ActiveRecord::Base.transaction do
      current_induction_record.changing!(end_date)

      Induction::Enrol.call(participant_profile: participant_profile,
                            induction_programme: new_induction_programme,
                            start_date: start_date,
                            preferred_email: preferred_email)
    end
  end

private

  attr_reader :participant_profile, :new_induction_programme, :start_date, :end_date

  def initialize(participant_profile:, end_date:, new_induction_programme:, start_date: Time.zone.now)
    @participant_profile = participant_profile
    @new_induction_programme = new_induction_programme
    @start_date = start_date
    @end_date = end_date
  end

  def current_induction_record
    participant_profile.current_induction_record
  end

  def current_induction_programme
    participant_profile.current_induction_record&.induction_programme
  end

  def preferred_email
    current_induction_record&.preferred_identity&.email || participant_profile.participant_identity.email
  end
end
