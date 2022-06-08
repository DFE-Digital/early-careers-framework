# frozen_string_literal: true

require "securerandom"

module Seeds
  class NPQApplication
    attr_reader :cpd_lead_provider

    def initialize(cpd_lead_provider:)
      @cpd_lead_provider = cpd_lead_provider
    end

    def call
      return if Rails.env.production?

      NPQ::BuildApplication.call(
        npq_application_params: {
          active_alert: false,
          date_of_birth: rand(60.years.ago.to_date..23.years.ago.to_date),
          teacher_reference_number: trn,
          eligible_for_funding: eligible_for_funding?,
          funding_choice: ::NPQApplication.funding_choices.keys.sample,
          headteacher_status: ::NPQApplication.headteacher_statuses.keys.sample,
          nino: SecureRandom.hex,
          school_urn: "000001",
          school_ukprn: "000001",
          teacher_reference_number_verified: true,
          works_in_school:,
          employer_name:,
          employment_role:,
          works_in_nursery:,
          works_in_childcare:,
          kind_of_nursery:,
          private_childcare_provider_urn:,
          funding_eligiblity_status_code:,
        },
        npq_course_id: NPQCourse.all.sample.id,
        npq_lead_provider_id: npq_lead_provider.id,
        user_id: user.id,
      ).tap(&:save!)
    end

  private

    def employer_name
      @employer_name ||= "Name of employer here"
    end

    def works_in_school
      @works_in_school ||= [true, false].sample
    end

    def works_in_nursery
      works_in_childcare
    end

    def works_in_childcare
      @works_in_childcare ||= !works_in_school
    end

    def kind_of_nursery
      @kind_of_nursery = %w[
        local_authority_maintained_nursery
        preschool_class_as_part_of_school
        private_nursery
      ].sample
    end

    def private_nursery?
      kind_of_nursery == "private_nursery"
    end

    def private_childcare_provider_urn
      "EY123456" if private_nursery?
    end

    def eligible_for_funding?
      @eligible_for_funding ||= [true, false].sample
    end

    def funding_eligiblity_status_code
      return "funded" if eligible_for_funding?
      return "not_on_early_years_register" if private_nursery?

      "ineligible_establishment_type"
    end

    def employment_role
      @employment_role ||= [
        "Teacher",
        "Manager",
        "Support Staff",
        "Business Owner",
        "Admin Staff",
      ].sample
    end

    def trn
      @trn ||= rand(1_000_000..9_999_999).to_s
    end

    def user
      @user ||= User.find_or_create_by!(email:) do |u|
        u.full_name = "NPQ User"
      end
    end

    def email
      @email ||= "#{email_local_part}@example.com"
    end

    def email_local_part
      @email_local_part ||= SecureRandom.uuid
    end

    def npq_lead_provider
      cpd_lead_provider.npq_lead_provider
    end
  end
end
