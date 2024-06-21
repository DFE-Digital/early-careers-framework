# frozen_string_literal: true

module Archive
  class UndeclaredUser < UnvalidatedUser
  private

    attr_accessor :cohort

    def initialize(user, cohort_year: 2021, reason: "undeclared participants in 2021", keep_original: false)
      super(user, reason:, keep_original:)

      @cohort = Cohort.find_by(start_year: cohort_year)
    end

    def check_user_can_be_archived!
      if users_excluded_roles.any?
        raise ArchiveError, "User #{user.id} has excluded roles: #{users_excluded_roles.join(',')}"
      elsif other_user_cohorts.any?
        raise ArchiveError, "User #{user.id} is in other cohorts: #{other_user_cohorts.join(',')}"
      elsif user_has_declarations?
        raise ArchiveError, "User #{user.id} has non-voided declarations"
      elsif user_has_mentees?
        raise ArchiveError, "User #{user.id} has mentees"
      elsif user_has_been_transferred?
        raise ArchiveError, "User #{user.id} has transfer records"
      elsif user_has_gai_id?
        raise ArchiveError, "User #{user.id} has a Get an Identity ID"
      elsif user_is_mentor_on_declarations?
        raise ArchiveError, "User #{user.id} is mentor on declarations"
      end
    end

    def other_user_cohorts
      @other_user_cohorts ||= user.participant_profiles.ecf.joins(:schedule).where.not(schedule: { cohort: }).map { |profile| profile.schedule.cohort.start_year }
    end

    def user_has_declarations?
      profile_ids = user.participant_profiles.pluck(:id)
      # handle bad data case where user_id might be on declarations not associated with the users profiles
      # in this case it doesn't matter whether they're voided or not, removing the user will cause issues.
      ParticipantDeclaration.where.not(state: %w[submitted ineligible voided]).where(participant_profile_id: profile_ids).any? ||
        ParticipantDeclaration.where(user_id: user.id).where.not(participant_profile_id: profile_ids).any?
    end
  end
end
