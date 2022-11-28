# frozen_string_literal: true

require "active_support/testing/time_helpers"

module Importers
  module SeedBPNDeclarations
    include ActiveSupport::Testing::TimeHelpers

    def create_participant(ecf_factory_class, user, school_cohort)
      ecf_factory_class.call(email: user.email, full_name: user.full_name, school_cohort:)
    end

    def change_participant_schedule(participant_profile, schedule, lead_provider)
      ChangeSchedule.new(
        participant_id: participant_profile.user_id,
        cpd_lead_provider: lead_provider.cpd_lead_provider,
        course_identifier: course_identifer_for(participant_profile),
        schedule_identifier: schedule.schedule_identifier,
      ).call
      participant_profile
    end

    def course_identifer_for(participant_profile)
      participant_profile.is_a?(ParticipantProfile::ECF::Mentor) ? "ecf-mentor" : "ecf-induction"
    end

    def record_started_declaration(participant_profile, interval, lead_provider)
      declaration_date = random_date_between(interval.begin, interval.end)
      travel_to(declaration_date) do
        record_started_one_declaration_class(participant_profile)
          .call(
            params: {
              cpd_lead_provider: lead_provider.cpd_lead_provider,
              declaration_date: declaration_date.rfc3339,
              participant_id: participant_profile.user_id,
              course_identifier: course_identifer_for(participant_profile),
              declaration_type: "started",
            },
          )
      end
      participant_profile
    end

    def record_backdated_started_declaration(participant_profile, interval, lead_provider, declaration_date_interval)
      declaration_date = random_date_between(declaration_date_interval.begin, declaration_date_interval.end)
      travel_to(random_date_between(interval.begin, interval.end)) do
        record_started_one_declaration_class(participant_profile)
          .call(
            params: {
              cpd_lead_provider: lead_provider.cpd_lead_provider,
              declaration_date: declaration_date.rfc3339,
              participant_id: participant_profile.user_id,
              course_identifier: course_identifer_for(participant_profile),
              declaration_type: "started",
            },
          )
      end
      participant_profile
    end

    def make_declaration_eligible(participant_profile)
      RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile.call(participant_profile:)
      participant_profile
    end

    def record_retain_one_declaration_class(participant_profile)
      participant_profile.is_a?(ParticipantProfile::ECF::Mentor) ? RecordDeclarations::Retained::Mentor : RecordDeclarations::Retained::EarlyCareerTeacher
    end

    def record_started_one_declaration_class(participant_profile)
      participant_profile.is_a?(ParticipantProfile::ECF::Mentor) ? RecordDeclarations::Started::Mentor : RecordDeclarations::Started::EarlyCareerTeacher
    end

    def create_retained_one_declaration(participant_profile, lead_provider, interval)
      declaration_date = random_date_between(interval.begin, interval.end)
      travel_to(declaration_date) do
        record_retain_one_declaration_class(participant_profile).call(
          params: {
            cpd_lead_provider: lead_provider.cpd_lead_provider,
            declaration_date: declaration_date.rfc3339,
            participant_id: participant_profile.user_id,
            course_identifier: course_identifer_for(participant_profile),
            declaration_type: "retained-1",
            evidence_held: "other",
          },
        )
      end
      participant_profile
    end

    def random_date_between(start_date, end_date)
      start_date == end_date ? start_date : (start_date.to_datetime..end_date.to_datetime).to_a.sample # rubocop:disable Style/DateTime
    end
  end
end
