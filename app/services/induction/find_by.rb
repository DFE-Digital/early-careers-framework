# frozen_string_literal: true

class Induction::FindBy < BaseService
  def call
    query = participant_profile.induction_records

    query = add_provider_to(query:) if lead_provider.present? || delivery_partner.present?
    query = add_schedule_to(query:) if schedule.present?
    query = add_school_to(query:) if school.present?
    query = add_date_range_to(query:) if date_range.present?

    query = query.current if current_not_latest_record
    query.latest
  end

private

  attr_reader :participant_profile, :lead_provider, :delivery_partner, :schedule, :school, :date_range, :current_not_latest_record

  def initialize(participant_profile:, lead_provider: nil, delivery_partner: nil, schedule: nil, school: nil, date_range: nil, current_not_latest_record: false)
    @participant_profile = participant_profile
    @lead_provider = lead_provider
    @delivery_partner = delivery_partner
    @schedule = schedule
    @school = school
    @date_range = date_range
    @current_not_latest_record = current_not_latest_record
  end

  def add_provider_to(query:)
    partnerships = {
      lead_provider:,
      delivery_partner:,
    }.compact_blank

    query.joins(induction_programme: :partnership).where(induction_programme: { partnerships: })
  end

  def add_schedule_to(query:)
    query.where(schedule:)
  end

  def add_school_to(query:)
    query.joins(induction_programme: :school_cohort).where(induction_programme: { school_cohorts: { school: } })
  end

  def add_date_range_to(query:)
    query.where(start_date: date_range)
  end
end
