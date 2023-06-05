# frozen_string_literal: true

module NewSeeds
  module Scenarios
    class NPQ
      attr_reader :user, :application, :participant_identity, :npq_lead_provider, :npq_course, :cohort, :declaration

      def initialize(user: nil, lead_provider: nil, npq_course: nil, cohort: nil)
        @supplied_user = user
        @supplied_lead_provider = lead_provider
        @supplied_npq_course = npq_course
        @supplied_cohort = cohort
      end

      def build
        @user = @supplied_user || FactoryBot.create(:seed_user, :valid)
        @npq_lead_provider = @supplied_lead_provider || FactoryBot.create(:seed_npq_lead_provider, :valid)
        @npq_course = @supplied_npq_course || FactoryBot.create(:seed_npq_course, :valid)
        @cohort = @supplied_cohort || Cohort.current || FactoryBot.create(:seed_cohort, :valid)

        @participant_identity = user&.participant_identities&.sample ||
          FactoryBot.create(:seed_participant_identity, user:)

        @application = FactoryBot.create(
          :seed_npq_application,
          :valid,
          participant_identity:,
          npq_lead_provider:,
          npq_course:,
          cohort:,
        )

        self
      end

      def accept_application
        raise(StandardError, "no npq application, call #build first") if application.blank?

        FactoryBot.create(:seed_npq_participant_profile_state, :valid, participant_profile:)

        participant_profile.teacher_profile.update!(trn: application.teacher_reference_number)
        application.update!(lead_provider_approval_status: "accepted")

        self
      end

      def participant_profile
        @participant_profile ||=
          FactoryBot.create(
            :seed_npq_participant_profile,
            user:,
            participant_identity:,
            npq_application: application,
            npq_course:,
            school_urn: application.school_urn,
            school_ukprn: application.school_ukprn,
            schedule: NPQCourse.schedule_for(npq_course:, cohort:),
            # it turns out that we don't find the NPQ application via the participant identity but
            # instead by the `has_one` on participant profile. The id of the NPQ application needs
            # to match the corresponding participant profile's id.
            id: application.id,
          )
      end

      def reject_application
        raise(StandardError, "no npq application, call #build first") if application.blank?

        application.update!(lead_provider_approval_status: "rejected")

        self
      end

      def edge_cases
        employment_type = %w[hospital_school
                             other
                             local_authority_virtual_school
                             young_offender_institution
                             local_authority_supply_teacher]
        employment_role = ["Head of Education",
                           "Vocational Leader",
                           "Online Teacher",
                           "Education manager",
                           "Tutor of English"]
        employer_name = ["Learning Partnership West Independent School",
                         "Salford County Council",
                         "Havant and South Downs College",
                         "Independent Special School",
                         "Feltham Young Offenders Institution"]
        application.update!(works_in_school: false,
                            works_in_childcare: false,
                            employment_type: employment_type.sample,
                            employment_role: employment_role.sample,
                            employer_name: employer_name.sample,
                            eligible_for_funding: false,
                            funding_eligiblity_status_code: "no_institution",
                            created_at: rand(60.years.ago.to_date..23.years.ago.to_date)
                          )
      end

      def add_declaration
        raise(StandardError, "no participant_profile, call #accept_application first") if participant_profile.blank?

        @declaration = FactoryBot.create(
          :seed_npq_participant_declaration,
          user:,
          participant_profile:,
          course_identifier: npq_course.identifier,
          cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
        )

        self
      end
    end
  end
end
