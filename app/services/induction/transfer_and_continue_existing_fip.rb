# frozen_string_literal: true

class Induction::TransferAndContinueExistingFIP < BaseService
  def call
    check_fip_induction_and_different_school!

    ActiveRecord::Base.transaction do
      # we haven't already been informed this person is leaving
      if latest_induction_record.active_induction_status?
        latest_induction_record.leaving!(end_date)
      end

      # create a special programme to support the transferring participant
      programme = InductionProgramme.create!(training_programme: :full_induction_programme,
                                             school_cohort: school_cohort,
                                             partnership: create_relationship)

      Induction::Enrol.call(participant_profile: participant_profile,
                            induction_programme: programme,
                            start_date: start_date,
                            preferred_identity: preferred_identity,
                            mentor_profile: mentor_profile)
    end
  end

private

  attr_reader :school_cohort, :participant_profile, :email, :start_date, :end_date, :mentor_profile

  def initialize(school_cohort:, participant_profile:, email: nil, start_date: Time.zone.now, end_date: nil, mentor_profile: nil)
    @school_cohort = school_cohort
    @participant_profile = participant_profile
    @email = email
    @start_date = start_date
    @end_date = end_date || start_date
    @mentor_profile = mentor_profile
  end

  def create_relationship
    if participant_lead_provider.present?
      Induction::CreateRelationship.call(school_cohort: school_cohort,
                                         lead_provider: participant_lead_provider,
                                         delivery_partner: participant_delivery_partner)
    end
  end

  def latest_induction_record
    participant_profile.induction_records.latest
  end

  def current_induction_programme
    latest_induction_record&.induction_programme
  end

  def participant_lead_provider
    current_induction_programme&.lead_provider
  end

  def participant_delivery_partner
    current_induction_programme&.delivery_partner
  end

  def preferred_identity
    if email.present?
      Identity::Create.call(user: participant_profile.participant_identity.user,
                            email: email)
    else
      participant_profile.participant_identity
    end
  end

  def check_fip_induction_and_different_school!
    raise ArgumentError "Participant is not enrolled in a FIP" unless latest_induction_record.enrolled_in_fip?
    raise ArgumentError "Participant is already enrolled at this school" if latest_induction_record.school == school_cohort.school
  end
end
