# frozen_string_literal: true

class DetermineTrainingRecordState < BaseService
  attr_reader :participant_profiles, :induction_records, :delivery_partner, :appropriate_body, :school

  def call
    participant_profiles.reduce({}) do |hash, participant_profile|
      induction_record = induction_records.find { |ir| ir.participant_profile_id = participant_profile.id }
      hash[participant_profile.id] = TrainingRecordState.new(participant_profile:, induction_record:)
    end
  end

private

  def initialize(participant_profiles:, induction_records: nil, delivery_partner: nil, appropriate_body: nil, school: nil)
    @participant_profiles = participant_profiles
      .joins("LEFT JOIN email_associations ON email_associations.object_id = participant_profiles.id")
      .joins("LEFT JOIN emails ON emails.id = email_associations.email_id AND 'request_for_details' = ANY (tags)")
      .select(
        "participant_profiles.*",
        "emails.status AS transient_request_for_details_status",
        "EXISTS (
          SELECT 1 FROM induction_records as mir
            WHERE mir.mentor_profile_id = participant_profiles.id
          ) AS transient_mentees",
        "EXISTS (
          SELECT 1 FROM induction_records as cmir
            WHERE cmir.mentor_profile_id = participant_profiles.id
              AND (cmir.induction_status = 'active' OR cmir.induction_status = 'leaving')
          ) AS transient_current_mentees",
      )
    @delivery_partner = delivery_partner
    @appropriate_body = appropriate_body
    @school = school
    @induction_records = induction_records || query_latest_induction_records
  end

  def query_latest_induction_records
    query = InductionRecord
      .joins("JOIN (#{latest_induction_records_join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")

    if school.present? || appropriate_body.present?
      school_cohorts = {
        school:,
        appropriate_body:,
      }.compact_blank

      query.joins(induction_programme: :school_cohort).where(induction_programme: { school_cohorts: })
    end

    if delivery_partner.present?
      query.joins(induction_programme: :partnership).where(induction_programme: { partnerships: { delivery_partner: } })
    end

    query
  end

  def latest_induction_records_join
    InductionRecord
      .select(Arel.sql("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id"))
  end

  def latest_induction_record_order
    <<~SQL
      PARTITION BY induction_records.participant_profile_id ORDER BY
        CASE
          WHEN induction_records.end_date IS NULL
            THEN 1
          ELSE 2
        END,
        induction_records.start_date DESC,
        induction_records.created_at DESC
    SQL
  end
end
