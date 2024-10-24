# frozen_string_literal: true

class Finance::Schedule::NPQ < Finance::Schedule
  def npq?
    true
  end
end

require "finance/schedule/npq_leadership"
require "finance/schedule/npq_specialist"
require "finance/schedule/npq_support"
