# frozen_string_literal: true

class NominationEmail < ApplicationRecord
  belongs_to :school

  NOMINATION_EXPIRY_TIME = 7.days

  def nomination_expired?
    (sent_at + NOMINATION_EXPIRY_TIME) < Time.zone.now
  end

  def tutor_already_nominated?
    school.induction_coordinator_profiles.count.positive?
  end
end
