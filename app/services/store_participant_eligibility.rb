# frozen_string_literal: true

class StoreParticipantEligibility < BaseService
  attr_reader :participant_profile, :eligibility_options

  def initialize(participant_profile:, eligibility_options: {})
    @participant_profile = participant_profile
    @eligibility_options = eligibility_options
  end

  def call
    @participant_eligibility = ECFParticipantEligibility.find_or_initialize_by(participant_profile: participant_profile)

    grab_current_eligibility_state

    update_and_store_eligibility_values!

    RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile.call(participant_profile: participant_profile) if changed_to_eligible?
    if (changed_to_ineligible? || changed_ineligible_reason?) && FeatureFlag.active?(:eligibility_notifications)
      send_ineligible_notification_email
    end

    @participant_eligibility
  end

private

  def grab_current_eligibility_state
    @previous_status = @participant_eligibility.status
    @previous_reason = @participant_eligibility.reason
  end

  def changed_to_ineligible?
    @participant_eligibility.ineligible_status? && @previous_status != "ineligible"
  end

  def changed_to_eligible?
    @participant_eligibility.eligible_status? && @previous_status != "eligible"
  end

  def changed_ineligible_reason?
    @participant_eligibility.ineligible_status? && @participant_eligibility.reason != @previous_reason
  end

  def send_ineligible_notification_email
    participant_profile.school_cohort.school.induction_coordinators.each do |induction_tutor|
      mailer_name = "#{participant_profile.participant_type}_#{@participant_eligibility.reason}_email"
      if IneligibleParticipantMailer.respond_to? mailer_name
        IneligibleParticipantMailer.send(mailer_name, **{ induction_tutor_email: induction_tutor.email, participant_profile: participant_profile }).deliver_later
      else
        Sentry.capture_message("Could not send ineligible participant notification [#{mailer_name}] for #{participant_profile.teacher_profile.user.email}")
      end
    end
  end

  def update_and_store_eligibility_values!
    if @participant_eligibility.new_record?
      @participant_eligibility.assign_attributes(default_eligibility_flags.merge(eligibility_options))
    else
      @participant_eligibility.assign_attributes(eligibility_options)
    end

    @participant_eligibility.determine_status
    @participant_eligibility.save!
    Analytics::ECFValidationService.upsert_record(participant_profile)
  end

  def default_eligibility_flags
    {
      active_flags: false,
      qts: true,
      previous_participation: false,
      previous_induction: false,
      different_trn: false,
    }
  end
end
