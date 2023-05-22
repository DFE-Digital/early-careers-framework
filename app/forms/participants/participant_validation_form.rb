# frozen_string_literal: true

module Participants
  class ParticipantValidationForm
    include Multistep::Form

    # @param [Hash] data
    #   * :trn [String]
    #   * :nino [String]
    #   * :date_of_birth [Date]
    #   * :full_name [String]
    def self.call(participant_profile, save_validation_data_without_match: true, data: nil)
      validation_data = if data.present?
                          OpenStruct.new(data)
                        else
                          participant_profile.ecf_participant_validation_data
                        end
      return false if validation_data.blank?

      new(
        participant_profile_id: participant_profile.id,
        trn: validation_data.trn,
        no_trn: validation_data.trn.blank?,
        nino: validation_data.nino,
        dob: validation_data.date_of_birth,
        full_name: validation_data.full_name,
      ).call(save_validation_data_without_match:)
    end

    # lifted from https://github.com/dwp/nino-format-validation
    NINO_REGEX = /(^(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-Z&&[^DFIQUV]][A-Z&&[^DFIOQUV]][0-9]{6}[A-D]$)/
    EXTRA_STEPS = %i[nino name_changed].freeze

    attribute :participant_profile_id
    attribute :eligibility
    attribute :dqt_response
    attribute :attempts, default: 0

    step :check_trn_given, update: true do
      attribute :check_trn_given, :boolean

      validates :check_trn_given, inclusion: { in: [true, false], message: :blank }

      next_step { check_trn_given ? :trn : :get_a_trn }
    end

    step :get_a_trn

    step :trn, update: true do
      attribute :trn, :string
      attribute :no_trn, :boolean, default: false

      validates :trn,
                teacher_reference_number: { message_scope: "errors.teacher_reference_number_personalised" },
                unless: :no_trn

      before_complete { check_eligibility! if dob.present? && !no_trn }
      next_step { no_trn ? :nino : :dob }
    end

    step :nino, update: true do
      attribute :nino, :string

      validates :nino,
                presence: true,
                format: { with: NINO_REGEX }

      before_complete { check_eligibility! if dob.present? }
      next_step { dob.present? ? eligibility : :dob }
    end

    step :dob, update: true do
      attribute :dob, :date

      validates :dob,
                presence: true,
                inclusion: {
                  in: ->(_) { (Date.new(1900, 1, 1))..(Date.current - 18.years) },
                  message: :invalid,
                }

      before_complete { check_eligibility! }
      next_step { eligibility }
    end

    step :name_changed do
      attribute :name_changed, :boolean

      validates :name_changed, inclusion: { in: [true, false], message: :blank }

      next_step { name_changed ? :name : :no_match }
    end

    step :name, update: true do
      attribute :full_name

      validates :full_name, presence: true

      before_complete { check_eligibility! }
      next_step { eligibility }
    end

    step :no_match, multiple: true do
      before_complete { store_validation_result! if additional_step == :manual_check }
      next_step { additional_step }
    end

    step :eligible
    step :manual_check
    step :ineligible
    step :secondary_fip_mentor_eligible
    step :previous_participation
    step :exempt_from_induction

    def trn=(value)
      super(value&.squish)
    end

    def nino=(value)
      super(value&.gsub(/\W/, ""))
    end

    def full_name
      super || participant_profile && participant_profile.user.full_name
    end

    def check_eligibility!
      self.dqt_response = ParticipantValidationService.validate(
        full_name:,
        trn: formatted_trn,
        date_of_birth: dob,
        nino:,
        config: {
          check_first_name_only: true,
        },
      )

      self.attempts += 1
      store_analytics!

      return self.eligibility = :no_match if dqt_response.blank?

      eligibility_record = store_validation_result!
      self.eligibility = eligibility_record.status.to_sym

      if eligibility_record.ineligible_status?
        if eligibility_record.duplicate_profile_reason?
          self.eligibility = :secondary_fip_mentor_eligible
        elsif eligibility_record.previous_participation_reason?
          self.eligibility = :previous_participation
        elsif eligibility_record.exempt_from_induction_reason?
          self.eligibility = :exempt_from_induction
        end
      end
    end

    def store_validation_result!(save_validation_data_without_match: true)
      return unless dqt_response || save_validation_data_without_match

      StoreValidationResult.call(
        participant_profile:,
        validation_data: {
          trn: formatted_trn,
          nino:,
          full_name:,
          dob:,
        },
        dqt_response:,
      )
    end

    def change_participant_cohort_and_induction_start_date!
      Participants::SyncDqtInductionStartDate.call(dqt_response[:induction_start_date], participant_profile) unless dqt_response.blank?
    end

    def store_analytics!
      Analytics::RecordValidationJob.perform_later(
        participant_profile:,
        real_time_attempts: attempts,
        real_time_success: dqt_response.present?,
        nino_entered: nino.present?,
      )
    end

    def participant_profile
      return if participant_profile_id.blank?

      @participant_profile ||= ParticipantProfile.find(participant_profile_id)
    end

    def additional_step
      (EXTRA_STEPS - completed_steps).first || :manual_check
    end

    def formatted_trn
      TeacherReferenceNumber.new(trn).formatted_trn
    end

    def call(save_validation_data_without_match: true)
      check_eligibility!
      store_validation_result!(save_validation_data_without_match:)
      change_participant_cohort_and_induction_start_date!
    end
  end
end
