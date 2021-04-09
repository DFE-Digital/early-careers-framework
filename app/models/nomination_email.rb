# frozen_string_literal: true

class NominationEmail < ApplicationRecord
  belongs_to :school

  NOMINATION_EXPIRY_TIME = 7.days

  def expired?
    !sent_within_last?(NOMINATION_EXPIRY_TIME)
  end

  def sent_within_last?(relative_time)
    (sent_at + relative_time) > Time.zone.now
  end
end
