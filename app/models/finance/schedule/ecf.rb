# frozen_string_literal: true

class Finance::Schedule::ECF < Finance::Schedule
  def self.default
    find_by(name: "ECF September standard 2021")
  end
end
