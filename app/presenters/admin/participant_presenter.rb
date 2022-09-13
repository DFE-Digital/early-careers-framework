# frozen_string_literal: true

module Admin
  class ParticipantPresenter
    attr_reader :participant_profile

    def initialize(participant_profile:)
      @participant_profile = participant_profile
    end

    delegate :npq?, to: :participant_profile
    delegate :ect?, to: :participant_profile
    delegate :notes, to: :participant_profile
    delegate :user, to: :participant_profile
    delegate :full_name, to: :user
    delegate :lead_provider, to: :school_cohort

    delegate :name, to: :school, prefix: "school", allow_nil: true
    delegate :urn, to: :school, prefix: "school", allow_nil: true
    delegate :friendly_id, to: :school, prefix: "school", allow_nil: true

    def date_of_birth
      participant_profile&.ecf_participant_validation_data&.date_of_birth&.to_s(:govuk)
    end

    def user_start_date
      user.created_at.to_date.to_s(:govuk)
    end

    def induction_start_date
      participant_profile&.induction_start_date&.to_s(:govuk)
    end

    def external_identifier
      latest_induction_record.participant_profile.participant_identity.external_identifier
    end

    def associated_email_addresses
      user.participant_identities.map(&:email)
    end

    def all_induction_records
      participant_profile.induction_records.sort_by(&:created_at).reverse
    end

    def latest_induction_record
      all_induction_records.first
    end

    def old_induction_records
      all_induction_records[1..]
    end

    def has_notes?
      notes.present?
    end

    def allow_withdrawal?(current_user)
      participant_profile.policy_class.new(current_user, participant_profile).withdraw_record?
    end

    def school_cohort
      latest_induction_record&.school_cohort
    end

    def school
      school_cohort&.school
    end

    def lead_provider_name
      school_cohort.lead_provider.name
    end

    def mentor_full_name
      latest_induction_record&.mentor_profile&.user&.full_name || "Not yet assigned"
    end

    def delivery_partner_name
      school_cohort.delivery_partner&.name
    end
  end
end
