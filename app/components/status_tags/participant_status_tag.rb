# frozen_string_literal: true

module StatusTags
  class ParticipantStatusTag < BaseComponent
    def initialize(profile:, induction_record: nil)
      @participant_profile = profile
      @induction_record = induction_record
    end

    def call
      if participant_profile.npq?
        render Admin::Participants::NPQValidationStatusTag.new(profile: participant_profile)
      else
        govuk_tag(**tag_attributes)
      end
    end

  private

    attr_reader :participant_profile, :induction_record

    def tag_attributes
      case record_state
      when :withdrawn_training
        { text: "Withdrawn by provider", colour: "red" }
      when :registered_for_fip_training, :registered_for_cip_training
        { text: "Eligible to start", colour: "green" }
      when :registered_for_mentor_training
        { text: "Eligible: Mentor at main school", colour: "green" }
      when :registered_for_mentor_training_second_school
        { text: "Eligible: Mentor at additional school", colour: "green" }
      when :not_qualified
        { text: "Not eligible: No QTS", colour: "red" }
      # when :active_flags
      # when :different_trn
      # when :no_induction_start
      when :manual_check
        { text: "DfE checking eligibility", colour: "orange" }
      when :previous_induction
        { text: "Not eligible: NQT+1", colour: "red" }
      when :previous_participation_ero
        { text: "Eligible to start: ERO", colour: "green" }
      when :previous_participation
        { text: "Eligible to start", colour: "green" }
      when :ineligible
        { text: "Not eligible", colour: "red" }
      when :request_for_details_delivered
        { text: "Contacted for information", colour: "grey" }
      when :request_for_details_failed
        { text: "Check email address", colour: "grey" }
      else
        { text: "Contacting for information", colour: "grey" }
      end
    end

    def record_state
      @record_state ||= ParticipantStatusTagStatus.new(
        participant_profile:,
        induction_record:,
      ).record_state
    end
  end
end
