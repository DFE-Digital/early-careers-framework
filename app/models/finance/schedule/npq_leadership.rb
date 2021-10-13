# frozen_string_literal: true

class Finance::Schedule::NPQLeadership < Finance::Schedule
  def self.default
    find_by(name: "NPQ Leadership November 2021")
  end
end
