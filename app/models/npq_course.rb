# frozen_string_literal: true

class NPQCourse < ApplicationRecord
  has_many :npq_applications

  def self.identifiers
    pluck(:identifier)
  end

  def self.schedule_for(npq_course)
    case npq_course.identifier
    when *Finance::Schedule::NPQLeadership::IDENTIFIERS
      Finance::Schedule::NPQLeadership.default
    when *Finance::Schedule::NPQSpecialist::IDENTIFIERS
      Finance::Schedule::NPQSpecialist.default
    when *Finance::Schedule::NPQSupport::IDENTIFIERS
      Finance::Schedule::NPQSupport.default
    else
      raise ArgumentError, "Invalid course identifier"
    end
  end
end
