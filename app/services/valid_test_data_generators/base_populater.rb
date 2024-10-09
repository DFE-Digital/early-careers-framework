# frozen_string_literal: true

require "active_support/testing/time_helpers"

module ValidTestDataGenerators
  class BasePopulater
    include ActiveSupport::Testing::TimeHelpers

    class << self
      def populate(name:, total_schools: 10, participants_per_school: 10, cohort: Cohort.current, number_of_participants: 100)
        new(name:, total_schools:, participants_per_school:, cohort:, number_of_participants:).populate
      end
    end

    def populate
      raise "Not implemented"
    end

  private

    attr_reader :lead_provider, :total_schools, :participants_per_school, :cohort, :number_of_participants, :npq_courses, :logger

    def initialize(name:, total_schools:, participants_per_school:, cohort:, number_of_participants:, logger: Rails.logger)
      @lead_provider = ::NPQLeadProvider.find_or_create_by!(name:)
      @total_schools = total_schools
      @participants_per_school = participants_per_school
      @cohort = cohort
      @number_of_participants = number_of_participants
      @logger = logger
      # Ignoring ASO course, is an old course which we shouldn't create data
      @npq_courses = NPQCourse.all.reject { |c| c.identifier == "npq-additional-support-offer" }
    end

    def create_application!(lead_provider:, school:, npq_course:, cohort:, participant_identity:)
      NPQApplication.create!(
        active_alert: "",
        date_of_birth: Date.new(1990, 1, 1),
        eligible_for_funding: true,
        funding_choice: "",
        headteacher_status: "",
        nino: "",
        school_urn: school.urn,
        teacher_reference_number: Helpers::TrnGenerator.next,
        teacher_reference_number_verified: true,
        npq_course:,
        npq_lead_provider: lead_provider,
        participant_identity:,
        cohort:,
      )
    end

    def create_applications!
      number_of_participants.times do
        user = create_user!
        participant_identity = Identity::Create.call(user:, origin: :npq)
        create_application!(lead_provider:, school: School.eligible.order("RANDOM()").first, npq_course:, cohort:, participant_identity:)
      end
    end

    def create_user!
      name = Faker::Name.name
      User.create!(full_name: name, email: Faker::Internet.email(name:))
    end

    def npq_course
      # NPQ-SENCO available only for >= 2024 cohorts
      cohort.start_year >= 2024 ? npq_courses.sample : npq_courses.reject { |c| c.identifier == "npq-senco" }.sample
    end
  end
end
