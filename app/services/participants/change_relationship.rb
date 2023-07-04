# frozen_string_literal: true

module Participants
  class ChangeRelationship < BaseService
    def call
      return if already_with_same_partnership?

      check_partnership_is_suitable!

      ActiveRecord::Base.transaction do
        create_induction_programme! if induction_programme.blank?

        if fixing_mistake
          change_for_mistake!
        else
          change_for_circumstance!
        end
      end
    end

  private

    attr_reader :induction_record, :partnership, :fixing_mistake

    def initialize(induction_record:, partnership:, fixing_mistake: false)
      @induction_record = induction_record
      @partnership = partnership
      @fixing_mistake = fixing_mistake
    end

    def change_for_mistake!
      check_participant_does_not_have_declarations_with_current_provider!
      old_induction_programme = induction_record.induction_programme

      induction_record.update!(induction_programme:)

      remove_old_induction_programme_if_possible!(old_induction_programme:)
    end

    def change_for_circumstance!
      Induction::ChangeInductionRecord.call(induction_record:, changes: { induction_programme: })
    end

    def check_participant_does_not_have_declarations_with_current_provider!
      raise ArgumentError, "Participant has declarations with current provider!" if has_declarations_with_current_provider?
    end

    def has_declarations_with_current_provider?
      ParticipantDeclaration::ECF.where(participant_profile:,
                                        cpd_lead_provider:).any?
    end

    def check_partnership_is_suitable!
      if partnership_in_a_different_cohort?
        raise ArgumentError, "This partnership is in a different cohort!"
      elsif partnership.challenged?
        raise ArgumentError, "This partnership has been challenged!"
      end
    end

    def current_partnership
      @current_partnership ||= induction_record.induction_programme.partnership
    end

    def already_with_same_partnership?
      current_partnership&.lead_provider_id == partnership.lead_provider_id &&
        current_partnership&.delivery_partner_id == partnership.delivery_partner_id
    end

    def partnership_in_a_different_cohort?
      current_partnership&.cohort != partnership.cohort
    end

    def school
      @school ||= partnership.school
    end

    def cohort
      @cohort ||= partnership.cohort
    end

    def school_cohort
      @school_cohort ||= SchoolCohort.find_by!(school:, cohort:)
    end

    def induction_programme
      @induction_programme ||= school_cohort.induction_programmes.find_by(partnership:)
    end

    def create_induction_programme!
      @induction_programme = school_cohort.induction_programmes.full_induction_programme.create!(partnership:)
    end

    def remove_old_induction_programme_if_possible!(old_induction_programme:)
      return if old_induction_programme.induction_records.any?
      return if old_induction_programme == school_cohort.default_induction_programme
      return unless old_induction_programme.partnership&.relationship?

      old_induction_programme.destroy!
    end

    def participant_profile
      induction_record.participant_profile
    end

    def cpd_lead_provider
      current_partnership.lead_provider.cpd_lead_provider
    end
  end
end
