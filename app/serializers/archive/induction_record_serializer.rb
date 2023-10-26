# frozen_string_literal: true

module Archive
  class InductionRecordSerializer
    include JSONAPI::Serializer

    set_id :id

    attribute :training_programme

    attribute :school_name
    attribute :school_urn

    attribute :lead_provider, &:lead_provider_name
    attribute :delivery_partner, &:delivery_partner_name
    attribute :core_materials, &:core_induction_programme_name
    attribute :appropriate_body, &:appropriate_body_name

    attribute :participant_profile_id
    attribute :schedule_id
    attribute :induction_programme_id
    attribute :induction_status
    attribute :training_status
    attribute :start_date
    attribute :end_date
    attribute :school_transfer
    attribute :preferred_identity_id
    attribute :mentor_profile_id
    attribute :appropriate_body_id
    attribute :created_at
  end
end
