# frozen_string_literal: true

require "tasks/school_urn_generator"
require "tasks/trn_generator"
require "active_support/testing/time_helpers"
require "tasks/valid_test_data_generator/base_populater"

module ValidTestDataGenerator
  class NPQLeadProviderPopulater < BasePopulater
    def populate
      return unless Rails.env.in?(%w[development review sandbox])

      logger.info "NPQLeadProviderPopulater: Started!"

      ActiveRecord::Base.transaction do
        generate_new_schools!
      end

      logger.info "NPQLeadProviderPopulater: Finished!"
    end

  private

    def generate_new_schools!
      total_schools.times { create_fip_school_with_cohort!(urn: SchoolURNGenerator.next) }
    end

    def find_or_create_participants!(school:)
      generate_new_participants!(school:)
    end

    def generate_new_participants!(school:)
      participants_per_school.times do
        create_participant!(school:)
      end
    end

    def create_participant!(school:)
      user = create_user!
      participant_identity = Identity::Create.call(user:, origin: :npq)
      npq_application = create_application!(lead_provider:, school:, npq_course:, cohort:, participant_identity:)

      return if Faker::Boolean.boolean(true_ratio: 0.3)

      accept_application(npq_application)

      return if Faker::Boolean.boolean(true_ratio: 0.3)

      # skip declarations for future courses
      return if %w[
        npq-early-headship-coaching-offer
        npq-early-years-leadership
        npq-leading-literacy
      ].include?(npq_application.npq_course.identifier)

      return if npq_application.profile.blank?

      started_declaration = create_started_declarations(npq_application)

      return if Faker::Boolean.boolean(true_ratio: 0.3)

      started_declaration.make_eligible!

      return if Faker::Boolean.boolean(true_ratio: 0.3)

      started_declaration.make_payable!
    end

    def accept_application(npq_application)
      npq_contract = NPQContract.where(
        cohort_id: cohort.id,
        npq_lead_provider_id: npq_application.npq_lead_provider_id,
        course_identifier: npq_application.npq_course.identifier,
      ).first
      return unless npq_contract

      funded_place = if npq_contract.funding_cap.to_i.positive?
                       npq_application.eligible_for_funding? ? Faker::Boolean.boolean(true_ratio: 0.3) : false
                     end

      NPQ::Application::Accept.new(npq_application:, funded_place:).call
      npq_application.reload
    end

    def create_started_declarations(npq_application)
      RecordDeclaration.new(
        participant_id: npq_application.user.id,
        course_identifier: npq_application.npq_course.identifier,
        declaration_date: (npq_application.profile.schedule.milestones.first.start_date + 1.day).rfc3339,
        cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
        declaration_type: "started",
      ).call
    end

    def create_fip_school_with_cohort!(urn:)
      school = School.find_or_create_by!(urn:) do |s|
        s.name = Faker::Company.name
        s.address_line1 = Faker::Address.street_address
        s.postcode = Faker::Address.postcode
      end
      find_or_create_participants!(school:)
    end
  end
end
