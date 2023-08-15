# frozen_string_literal: true

require "active_support/testing/time_helpers"

require_relative "mentor_in_training"

module NewSeeds
  module Scenarios
    module Participants
      module Mentors
        class MentorWithNPQApplication < NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
          delegate :npq_lead_provider,
                   :npq_course,
                   to: :npq_application_builder
          def npq_application = @npq_application_builder.application
          def npq_cohort = @npq_application_builder.cohort

          def ecf_cohort = school_cohort.cohort

          def initialize(school_cohort:, full_name: nil, email: nil, teacher_profile: nil, participant_identity: nil)
            @school = school_cohort.school
            @induction_programme = school_cohort.default_induction_programme

            super(school_cohort:, full_name:, email:, teacher_profile:, participant_identity:)
          end

          def build(**mentor_builder_args)
            # keep falsy values intact
            mentor_builder_args[:sparsity_uplift] = true unless mentor_builder_args.key?(:sparsity_uplift)
            mentor_builder_args[:pupil_premium_uplift] = true unless mentor_builder_args.key?(:pupil_premium_uplift)

            super(**mentor_builder_args)
            with_validation_data
            with_eligibility
            with_induction_record(induction_programme:, induction_status: "changed", start_date: Time.zone.local(2021, 12, 1, 12, 0), end_date: Time.zone.local(2022, 9, 8, 12, 38))
            with_induction_record(induction_programme:, training_status: "withdrawn", start_date: Time.zone.local(2022, 9, 8, 12, 38))

            # started declarations
            add_paid_declaration declaration_type: "started", declaration_date: Time.zone.local(2021, 12, 17, 13, 0)
            add_ineligible_declaration declaration_type: "started", declaration_date: Time.zone.local(2021, 12, 17, 13, 0)
            add_ineligible_declaration declaration_type: "started", declaration_date: Time.zone.local(2021, 12, 17, 13, 0)

            # retained-1 declaration
            add_paid_declaration declaration_type: "retained-1", declaration_date: Time.zone.local(2022, 3, 20, 13, 0)

            add_npq_application created_at: Time.zone.local(2023, 7, 12, 16, 47)

            self
          end

        private

          attr_reader :npq_application_builder, :induction_programme, :school

          def add_paid_declaration(declaration_type:, declaration_date:)
            cpd_lead_provider = induction_programme.partnership.lead_provider.cpd_lead_provider

            declaration = FactoryBot.create(
              :seed_ecf_participant_declaration,
              participant_profile:,
              user:,
              cpd_lead_provider:,
              declaration_type:,
              declaration_date:,
            )

            declaration.make_eligible!
            declaration.make_payable!
            declaration.make_paid!
          end

          def add_ineligible_declaration(declaration_type:, declaration_date:)
            cpd_lead_provider = induction_programme.partnership.lead_provider.cpd_lead_provider

            declaration = FactoryBot.create(
              :seed_ecf_participant_declaration,
              participant_profile:,
              user:,
              cpd_lead_provider:,
              declaration_type:,
              declaration_date:,
            )

            declaration.make_ineligible!
          end

          def add_npq_application(created_at:)
            @npq_application_builder = NewSeeds::Scenarios::NPQ
                                         .new(user:, cohort: school_cohort.cohort)
                                         .build

            npq_application_builder.application.update! school_urn: school.urn,
                                                        school_ukprn: school.ukprn,
                                                        teacher_reference_number: teacher_profile.trn,
                                                        created_at:,
                                                        updated_at: created_at
          end
        end
      end
    end
  end
end
