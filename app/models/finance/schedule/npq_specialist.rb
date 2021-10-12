# frozen_string_literal: true

class Finance::Schedule::NPQSpecialist < Finance::Schedule
  def self.default
    find_by(name: "NPQ Specialist November 2021")
  end
end
