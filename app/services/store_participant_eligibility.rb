# frozen_string_literal: true

class StoreParticipantEligibility < BaseService
  def call
    @participant_eligibility = ECFParticipantEligibility.find_or_initialize_by(participant_profile:)

    grab_current_eligibility_state

    update_and_store_eligibility_values!

    eligibility_triggers! if changed_to_eligible?

    if changed_to_eligible? && changed_from_ineligible? && changed_from_previous_induction? && doing_fip?
      send_now_eligible_email
    end

    if (changed_to_ineligible? || changed_ineligible_reason?) && doing_fip? && FeatureFlag.active?(:eligibility_notifications)
      send_ineligible_notification_emails
    end

    if changed_to_manual_check? && doing_fip?
      send_manual_check_notification_email
    end

    @participant_eligibility
  end

private

  attr_reader :participant_profile, :eligibility_options

  def initialize(participant_profile:, eligibility_options: {})
    @participant_profile = participant_profile
    @eligibility_options = eligibility_options
  end

  def eligibility_triggers!
    RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile.call(participant_profile:)
  end

  def grab_current_eligibility_state
    @previous_status = @participant_eligibility.status
    @previous_reason = @participant_eligibility.reason
    @new_eligibility_record = !@participant_eligibility.persisted?
  end

  def changed_to_ineligible?
    @participant_eligibility.ineligible_status? && @previous_status != "ineligible"
  end

  def changed_to_eligible?
    @participant_eligibility.eligible_status? && @previous_status != "eligible"
  end

  # We need to check if the record is new because "manual_check" is the default value for newly
  # created participant eligibilities
  def changed_to_manual_check?
    @participant_eligibility.manual_check_status? && ((@previous_status != "manual_check") || @new_eligibility_record)
  end

  def changed_from_ineligible?
    @previous_status == "ineligible"
  end

  def changed_from_previous_induction?
    @previous_reason == "previous_induction"
  end

  def changed_ineligible_reason?
    @participant_eligibility.ineligible_status? && @participant_eligibility.reason != @previous_reason
  end

  def doing_fip?
    @participant_eligibility.participant_profile.school_cohort.full_induction_programme?
  end

  def send_now_eligible_email
    participant_profile.school_cohort.school.induction_coordinators.each do |induction_tutor|
      IneligibleParticipantMailer.with(
        induction_tutor:,
        participant_profile:,
      ).ect_now_eligible_previous_induction_email.deliver_later
    end
  end

  def send_ineligible_notification_emails
    participant_profile.school_cohort.school.induction_coordinators.each do |induction_tutor|
      break unless ineligible_notification_email_for_induction_coordinator

      IneligibleParticipantMailer.with(
        induction_tutor_email: induction_tutor.email,
        participant_profile:,
      ).send(
        ineligible_notification_email_for_induction_coordinator,
      ).deliver_later
    end

    if @participant_eligibility.reason.to_sym == :exempt_from_induction
      if participant_profile.participant_declarations.any? && @previous_status == "eligible"
        IneligibleParticipantMailer.with(participant_profile:).ect_exempt_from_induction_email_to_ect_previously_eligible.deliver_later
      elsif @previous_status != "eligible"
        IneligibleParticipantMailer.with(participant_profile:).ect_exempt_from_induction_email_to_ect.deliver_later
      end
    end
  end

  def ineligible_notification_email_for_induction_coordinator
    return @ineligible_notification_email_for_induction_coordinator if defined?(@ineligible_notification_email_for_induction_coordinator)

    @email_for_induction_coordinator =
      case @participant_eligibility.reason.to_sym
      when :exempt_from_induction
        if participant_profile.participant_declarations.any? && @previous_status == "eligible"
          :ect_exempt_from_induction_email_previously_eligible
        elsif @previous_status == "eligible"
          nil
        else
          :ect_exempt_from_induction_email
        end

      when :previous_induction
        if @previous_status == "eligible"
          :ect_previous_induction_email_previously_eligible
        else
          :ect_previous_induction_email
        end

      else
        mailer_name = "#{participant_profile.participant_type}_#{@participant_eligibility.reason}_email"
        unless mailer_name == "mentor_previous_participation_email" # Do not send emails about ERO mentors
          if IneligibleParticipantMailer.respond_to? mailer_name
            mailer_name
          else
            Sentry.capture_message("Could not send ineligible participant notification [#{mailer_name}] for #{participant_profile.teacher_profile.user.email}")
            nil
          end
        end
      end
  end

  def send_manual_check_notification_email
    if @participant_eligibility.reason.to_sym == :no_induction
      participant_profile.school_cohort.school.induction_coordinators.each do |induction_tutor|
        IneligibleParticipantMailer.with(induction_tutor_email: induction_tutor.email, participant_profile:).ect_no_induction_email.deliver_later
      end
    end
  end

  def update_and_store_eligibility_values!
    if @participant_eligibility.new_record?
      @participant_eligibility.assign_attributes(default_eligibility_flags.merge(eligibility_options))
    else
      @participant_eligibility.assign_attributes(eligibility_options)
    end

    Participants::DetermineEligibilityStatus.call(ecf_participant_eligibility: @participant_eligibility)

    # Analytics::UpsertECFParticipantProfileJob.perform_later(participant_profile:)
  end

  def default_eligibility_flags
    {
      active_flags: false,
      qts: true,
      previous_participation: false,
      previous_induction: false,
      different_trn: false,
      no_induction: false,
      exempt_from_induction: false,
    }
  end
end
