# frozen_string_literal: true

module Archive
  class FrozenCohortProfile < UnvalidatedProfile
  private

    def initialize(participant_profile, reason: "undeclared participants in frozen cohort", keep_original: false)
      super
    end

    def check_profile_can_be_archived!
      if profile_not_archivable_from_cohort?
        raise ArchiveError, "Profile #{participant_profile.id} cannot be archived from the #{cohort.start_year} cohort"
      end
    end

    def profile_not_archivable_from_cohort?
      !participant_profile.archivable_from_frozen_cohort?
    end

    def cohort
      @cohort ||= participant_profile.schedule.cohort
    end
  end
end
