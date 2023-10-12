# frozen_string_literal: true

module Archive
  class NPQApplicationSerializer
    include JSONAPI::Serializer

    set_id :id

    attribute :participant_identity_id
    attribute :npq_lead_provider_id
    attribute :npq_course_id
    attribute :date_of_birth
    attribute :teacher_reference_number
    attribute :teacher_reference_number_verified
    attribute :school_urn
    attribute :headteacher_status
    attribute :active_alert
    attribute :eligible_for_funding
    attribute :funding_choice
    attribute :nino
    attribute :lead_provider_approval_status
    attribute :school_ukprn
    attribute :created_at
    attribute :works_in_school
    attribute :employer_name
    attribute :employment_role
    attribute :targeted_support_funding_eligibility
    attribute :cohort_id
    attribute :targeted_delivery_funding_eligibility
    attribute :works_in_nursery
    attribute :works_in_childcare
    attribute :kind_of_nursery
    attribute :private_childcare_provider_urn
    attribute :funding_eligiblity_status_code
    attribute :teacher_catchment
    attribute :teacher_catchment_country
    attribute :employment_type
    attribute :teacher_catchment_iso_country_code
    attribute :itt_provider
    attribute :lead_mentor
    attribute :notes
    attribute :primary_establishment
    attribute :number_of_pupils
    attribute :tsf_primary_eligibility
    attribute :tsf_primary_plus_eligibility
    attribute :eligible_for_funding_updated_by_id
    attribute :eligible_for_funding_updated_at
  end
end
