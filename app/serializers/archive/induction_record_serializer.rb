# frozen_string_literal: true

module Archive
  class InductionRecordSerializer
    include JSONAPI::Serializer

    set_id :id

    meta do |induction_record|
      {
        school: induction_record.school.name_and_urn,
        schedule: induction_record.schedule.name,
        cohort: induction_record.schedule.cohort.start_year,
        appropriate_body: induction_record.appropriate_body_name,
        programme: induction_record.induction_programme.training_programme,
        lead_provider: induction_record.lead_provider_name,
        delivery_partner: induction_record.delivery_partner_name,
        core_materials: induction_record.core_induction_programme_name,
      }
    end

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

