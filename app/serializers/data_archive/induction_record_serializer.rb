# frozen_string_literal: true

module DataArchive
  class InductionRecordSerializer
    include JSONAPI::Serializer

    set_id :id

    attribute :school_name do |induction_record|
      induction_record.school.name
    end

    attribute :school_urn do |induction_record|
      induction_record.school.urn
    end

    attribute :schedule do |induction_record|
      induction_record.schedule.name
    end

    attribute :cohort do |induction_record|
      induction_record.schedule.cohort.start_year
    end

    attribute :training_programme do |induction_record|
      induction_record.induction_programme.training_programme
    end

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
