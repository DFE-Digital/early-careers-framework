# frozen_string_literal: true

module Archive
  class UndeclaredProfile < UnvalidatedProfile
  private

    attr_accessor :cohort

    def initialize(participant_profile, cohort_year: 2021, reason: "undeclared participants in 2021", keep_original: false)
      super(participant_profile, reason:, keep_original:)

      @cohort = Cohort.find_by(start_year: cohort_year)
    end

    def check_profile_can_be_archived!
      if profile_not_in_requested_cohort?
        raise ArchiveError, "Profile #{participant_profile.id} is not in #{cohort.start_year} cohort"
      elsif profile_has_declarations?
        raise ArchiveError, "Profile #{participant_profile.id} has non-voided declarations"
      elsif profile_has_mentees?
        raise ArchiveError, "Profile #{participant_profile.id} has mentees"
      end
    end

    def profile_not_in_requested_cohort?
      participant_profile.schedule.cohort != cohort
    end

    def profile_has_declarations?
      participant_profile.participant_declarations.where.not(state: %w[submitted ineligible voided]).any?
    end
  end
end
