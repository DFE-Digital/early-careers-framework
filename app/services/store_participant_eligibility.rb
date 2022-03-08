# frozen_string_literal: true

class StoreParticipantEligibility < BaseService
  def call
    @participant_eligibility = ECFParticipantEligibility.find_or_initialize_by(participant_profile: participant_profile)

    grab_current_eligibility_state

    update_and_store_eligibility_values!

    eligibility_triggers! if changed_to_eligible?

    if changed_to_eligible? && changed_from_ineligible? && changed_from_previous_induction? && doing_fip?
      send_now_eligible_email
    end

    if (changed_to_ineligible? || changed_ineligible_reason?) && doing_fip? && FeatureFlag.active?(:eligibility_notifications)
      send_ineligible_notification_email
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
    RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile.call(participant_profile: participant_profile)
  end

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

  def changed_to_manual_check?
    @participant_eligibility.manual_check_status? && @previous_status != "ineligible"
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
      IneligibleParticipantMailer.ect_now_eligible_previous_induction_email(
        induction_tutor_email: induction_tutor.email,
        participant_profile: participant_profile,
      ).deliver_later
    end
  end

  def send_ineligible_notification_email
    participant_profile.school_cohort.school.induction_coordinators.each do |induction_tutor|
      mailer_name = "#{participant_profile.participant_type}_#{@participant_eligibility.reason}_email"
      next if mailer_name == "mentor_previous_participation_email" # Do not send emails about ERO mentors

      case @participant_eligibility.reason.to_sym
      when :exempt_from_induction
        if participant_profile.participant_declarations.any? && @previous_status == "eligible"
          IneligibleParticipantMailer.ect_exempt_from_induction_email_previously_eligible(induction_tutor_email: induction_tutor.email, participant_profile: participant_profile).deliver_later
          # TODO: send this only once
          IneligibleParticipantMailer.ect_exempt_from_induction_email_to_ect_previously_eligible(participant_profile: participant_profile).deliver_later
        else
          IneligibleParticipantMailer.ect_exempt_from_induction_email(induction_tutor_email: induction_tutor.email, participant_profile: participant_profile).deliver_later
          # TODO: send this only once
          IneligibleParticipantMailer.ect_exempt_from_induction_email_to_ect(participant_profile: participant_profile).deliver_later
        end

      when :previous_induction
        if @previous_status == "eligible"
          IneligibleParticipantMailer.ect_previous_induction_email_previously_eligible(induction_tutor_email: induction_tutor.email, participant_profile: participant_profile).deliver_later
        else
          IneligibleParticipantMailer.ect_previous_induction_email(induction_tutor_email: induction_tutor.email, participant_profile: participant_profile).deliver_later
        end

      else
        if IneligibleParticipantMailer.respond_to? mailer_name
          IneligibleParticipantMailer.send(mailer_name, **{ induction_tutor_email: induction_tutor.email, participant_profile: participant_profile }).deliver_later
        else
          Sentry.capture_message("Could not send ineligible participant notification [#{mailer_name}] for #{participant_profile.teacher_profile.user.email}")
        end
      end
    end
  end

  def send_manual_check_notification_email
    if @participant_eligibility.reason.to_sym == :no_induction
      participant_profile.school_cohort.school.induction_coordinators.each do |induction_tutor|
        IneligibleParticipantMailer.ect_no_induction_email(induction_tutor_email: induction_tutor.email, participant_profile: participant_profile).deliver_later
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
    Analytics::UpsertECFParticipantProfileJob.perform_later(participant_profile: participant_profile)
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
