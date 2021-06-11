# frozen_string_literal: true

module DataStudio
  class FetchSchoolRolloutData < ::BaseService
    def call
      schools = School.arel_table
      nomination_emails = NominationEmail.arel_table
      induction_coordinator_profiles = InductionCoordinatorProfile.arel_table
      school_cohorts = SchoolCohort.arel_table
      partnerships = Partnership.arel_table
      users = User.arel_table

      School
        .eligible
        .left_joins(:nomination_emails)
        .left_joins(:induction_coordinator_profiles_schools)
        .left_joins(:induction_coordinator_profiles)
        .left_joins(induction_coordinator_profiles: :user)
        .left_joins(:school_cohorts)
        .left_joins(:partnerships)
        .select(
          schools[:id],
          schools[:name],
          schools[:urn],
          nomination_emails[:sent_at],
          nomination_emails[:opened_at],
          nomination_emails[:notify_status],
          induction_coordinator_profiles[:created_at].as("tutor_nominated_time"),
          users[:current_sign_in_at].as("induction_tutor_signed_in"),
          school_cohorts[:induction_programme_choice],
          school_cohorts[:created_at].as("programme_chosen_time"),
          partnerships[:created_at].as("partnership_time"),
        )
        .order(schools[:urn].asc, schools[:created_at].asc)
    end
  end
end
