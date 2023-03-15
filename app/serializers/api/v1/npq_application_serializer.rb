# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class NPQApplicationSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      attributes :course_identifier,
                 :email,
                 :email_validated,
                 :employer_name,
                 :employment_role,
                 :full_name,
                 :funding_choice,
                 :headteacher_status,
                 :ineligible_for_funding_reason,
                 :participant_id,
                 :private_childcare_provider_urn,
                 :teacher_reference_number,
                 :teacher_reference_number_validated,
                 :school_urn,
                 :school_ukprn,
                 :status,
                 :works_in_school

      attribute(:participant_id) do |object|
        object.participant_identity.user_id_or_external_identifier
      end

      attribute(:teacher_reference_number_validated, &:teacher_reference_number_verified)

      attribute(:full_name) do |object|
        object.participant_identity.user.full_name
      end

      attribute(:email) do |object|
        object.participant_identity.email
      end

      attribute(:email_validated) do
        true
      end

      attribute(:course_identifier) do |object|
        object.npq_course.identifier
      end

      attribute :created_at do |object|
        object.created_at.rfc3339
      end

      attribute :updated_at do |object|
        [
          object.profile&.updated_at,
          object.user.updated_at,
          object.participant_identity.updated_at,
          object.updated_at,
        ].compact.max.rfc3339
      end

      attribute(:status, &:lead_provider_approval_status)

      attribute :cohort do |object|
        object.cohort.start_year.to_s
      end

      attribute(:eligible_for_funding, &:eligible_for_dfe_funding)
      attribute(:targeted_delivery_funding_eligibility)

      attribute :teacher_catchment, &:in_uk_catchment_area?
      attribute :teacher_catchment_iso_country_code
      attribute :teacher_catchment_country
      attribute :itt_provider
      attribute :lead_mentor
    end
  end
end
