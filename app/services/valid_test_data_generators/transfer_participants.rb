# frozen_string_literal: true

require "active_support/testing/time_helpers"

module ValidTestDataGenerators
  class TransferParticipants
    class << self
      def call(name:, cohort: Cohort.current, number: 20)
        new(name:, cohort:).call(number:)
      end
    end

    def call(number:)
      number.times { transfer_participant }
    end

  private

    attr_reader :lead_provider, :cohort

    def initialize(name:, cohort:)
      @lead_provider = ::LeadProvider.find_by!(name:)
      @cohort = cohort
    end

    def transfer_participant
      participant_profile = find_untransferred_participant_profile
      return unless participant_profile

      if Faker::Boolean.boolean(true_ratio: 0.5)
        transfer_out(participant_profile:)
      else
        transfer_in(participant_profile:)
      end
    end

    def transfer_out(participant_profile:)
      participant_profile.latest_induction_record.leaving!(transferring_out: true)
    end

    def transfer_in(participant_profile:)
      existing_school = participant_profile.latest_induction_record.school
      if Faker::Boolean.boolean(true_ratio: 0.5)
        school_cohort = find_different_school_same_lead_provider(existing_school:)
        return unless school_cohort

        Induction::TransferAndContinueExistingFip.call(school_cohort:, participant_profile:)
      else
        other_induction_programme = find_different_school_different_lead_provider(existing_school:)&.default_induction_programme
        return unless other_induction_programme

        Induction::TransferToSchoolsProgramme.call(participant_profile:, induction_programme: other_induction_programme)
      end
    end

    def find_different_school_same_lead_provider(existing_school:)
      SchoolCohort
        .joins(:school, default_induction_programme: { partnership: :lead_provider })
        .where.not(school: existing_school)
        .where(default_induction_programme: { partnerships: { lead_provider: } })
        .order("RANDOM()")
        .first
    end

    def find_different_school_different_lead_provider(existing_school:)
      SchoolCohort
        .joins(:school, default_induction_programme: { partnership: :lead_provider })
        .where.not(school: existing_school)
        .where.not(default_induction_programme: { partnerships: { lead_provider: } })
        .order("RANDOM()")
        .first
    end

    def find_untransferred_participant_profile
      scope = Api::V3::ECF::ParticipantsQuery.new(lead_provider:, params: { filter: { cohorts: [cohort.start_year] } }).participants_for_pagination
      scope.where(induction_records: { induction_status: :active }).map(&:participant_profiles).flatten.select(&:ect?).sample
    end
  end
end
