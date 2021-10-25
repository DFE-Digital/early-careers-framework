# frozen_string_literal: true

module Participants
  class ParticipantValidationForm
    include Multistep::Form

    # lifted from https://github.com/dwp/nino-format-validation
    NINO_REGEX = /(^(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-Z&&[^DFIQUV]][A-Z&&[^DFIOQUV]][0-9]{6}[A-D]$)/.freeze
    EXTRA_STEPS = %i[nino name_changed].freeze

    attribute :participant_profile_id
    attribute :eligibility
    attribute :dtq_response

    step :trn, update: true do
      attribute :trn, :string
      attribute :no_trn, :boolean, default: false

      validates :trn,
                presence: true,
                format: { with: /\A\d+\z/ },
                length: { within: 5..7 },
                unless: :no_trn

      before_complete { check_eligibility! if dob.present? }
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
      next_step { additional_step }
    end

    step :eligible
    step :manual_check
    step :ineligible

    step :result

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
      self.dtq_response = ParticipantValidationService.validate(
        full_name: full_name,
        trn: trn,
        date_of_birth: dob,
        nino: nino,
      )

      return self.eligibility = :no_match if dtq_response.blank?

      eligibility_record = StoreValidationResult.call(
        participant_profile: participant_profile,
        validation_data: {
          trn: trn,
          nino: nino,
          full_name: full_name,
          dob: dob
        },
        dtq_response: dtq_response
      )

      self.eligibility = eligibility_record.status.to_sym
    end

    def participant_profile
      return if participant_profile_id.blank?

      @participant_profile ||= ParticipantProfile.find(participant_profile_id)
    end

    def additional_step
      (EXTRA_STEPS - completed_steps).first || :manual_check
    end
  end
end
