# frozen_string_literal: true

# This is related to Change of Circumstances / data model refactor
# We need to be able to differentiate between Partnerships that have been added by a provider
# and ones that have ben added by the school induction tutor as part of transferring in a participant
# that is remaining on their current FIP induction.  Basically they are the same thing
# but the business is calling the SIT added partnerships a "relationship" as a means to
# differentiate them.
class Induction::CreateRelationship < BaseService
  def call
    Partnership.find_or_create_by!(school: school_cohort.school,
                                   cohort: school_cohort.cohort,
                                   lead_provider:,
                                   delivery_partner:) do |partnership|
      partnership.relationship = !treat_as_partnership
      partnership.challenge_deadline = challenge_deadline
    end
  end

private

  attr_reader :school_cohort, :lead_provider, :delivery_partner, :treat_as_partnership

  def initialize(school_cohort:, lead_provider:, delivery_partner: nil, treat_as_partnership: false)
    @school_cohort = school_cohort
    @lead_provider = lead_provider
    @delivery_partner = delivery_partner
    @treat_as_partnership = treat_as_partnership
  end

  def challenge_deadline
    if treat_as_partnership
      Partnerships::Report::CHALLENGE_WINDOW.from_now
    else
      Time.zone.now
    end
  end
end
