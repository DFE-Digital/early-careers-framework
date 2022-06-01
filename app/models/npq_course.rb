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
    when *Finance::Schedule::NPQEhco::IDENTIFIERS
      Finance::Schedule::NPQEhco.default
    else
      raise ArgumentError, "Invalid course identifier"
    end
  end

  def rebranded_alternative_courses
    case identifier
    when "npq-additional-support-offer"
      [self, NPQCourse.find_by(identifier: "npq-early-headship-coaching-offer")]
    when "npq-early-headship-coaching-offer"
      [self, NPQCourse.find_by(identifier: "npq-additional-support-offer")]
    else
      [self]
    end
  end
end
