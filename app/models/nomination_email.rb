# frozen_string_literal: true

class NominationEmail < ApplicationRecord
  belongs_to :school

  NOMINATION_EXPIRY_TIME = 7.days

  def expired?
    (sent_at + NOMINATION_EXPIRY_TIME) < Time.zone.now
  end
end
