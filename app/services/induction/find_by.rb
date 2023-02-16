# frozen_string_literal: true

#####
## Retrieve the latest or current induction record, most relevant to optional parties
# required params:
#   participant_profile: the ECF profile of interest
#
# optional params:
#   lead_provider: restricts search to a LeadProvider
#   delivery_partner: restricts search to a DeliveryPartner
#   schedule: restricts search to a Schedule
#   school: restricts search to a School
#   date_range: restrict search to a date range e.g. Date.new(2022, 9, 1)..Date.new(2022, 11, 1)
#   current_not_latest_record: restrict search to "current" induction records only. Default false
#   only_active_partnerships: restirct lead_provider or delivery_partner searches to actvie partnerships only. Default false
#
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

  attr_reader :participant_profile, :lead_provider, :delivery_partner, :schedule, :school, :date_range, :current_not_latest_record, :only_active_partnerships

  def initialize(participant_profile:, lead_provider: nil, delivery_partner: nil, schedule: nil, school: nil, date_range: nil, current_not_latest_record: false, only_active_partnerships: false)
    @participant_profile = participant_profile
    @lead_provider = lead_provider
    @delivery_partner = delivery_partner
    @schedule = schedule
    @school = school
    @date_range = date_range
    @current_not_latest_record = current_not_latest_record
    @only_active_partnerships = only_active_partnerships
  end

  def add_provider_to(query:)
    partnerships = {
      lead_provider:,
      delivery_partner:,
    }.compact_blank

    if only_active_partnerships
      partnerships.merge!({
        challenged_at: nil,
        challenge_reason: nil,
        pending: false,
      })
    end

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
