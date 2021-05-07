# frozen_string_literal: true

class PartnershipRequest < BasePartnership
  after_create :schedule

  def finalise!
    ActiveRecord::Base.transaction do
      Partnership.create!(
        delivery_partner: delivery_partner,
        lead_provider: lead_provider,
        school: school,
        cohort: cohort,
        challenge_deadline: Time.zone.now,
      )
      school_cohort = SchoolCohort.find_by!(school_id: school_id, cohort_id: cohort_id)
      school_cohort.update!(induction_programme_choice: "full_induction_programme", core_induction_programme: nil)

      destroy!
    end
  end

  def challenge!(reason)
    raise ArgumentError if reason.blank?

    ActiveRecord::Base.transaction do
      Partnership.create!(
        delivery_partner: delivery_partner,
        lead_provider: lead_provider,
        school: school,
        cohort: cohort,
        challenge_reason: reason,
        challenged_at: Time.zone.now,
      )

      destroy!
    end
  end

private

  def schedule
    PartnershipFinalisationJob.set(wait: Partnership::CHALLENGE_WINDOW).perform_later(self)
  end
end
