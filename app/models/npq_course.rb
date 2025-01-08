# frozen_string_literal: true

class NPQCourse < ApplicationRecord
  def self.identifiers
    pluck(:identifier)
  end

  def self.schedule_for(npq_course:, cohort: Cohort.current)
    case npq_course.identifier
    when *Finance::Schedule::NPQLeadership::IDENTIFIERS
      Finance::Schedule::NPQLeadership.schedule_for(cohort:)
    when *Finance::Schedule::NPQSpecialist::IDENTIFIERS
      Finance::Schedule::NPQSpecialist.schedule_for(cohort:)
    when *Finance::Schedule::NPQSupport::IDENTIFIERS
      Finance::Schedule::NPQSupport.find_by!(cohort:)
    when *Finance::Schedule::NPQEhco::IDENTIFIERS
      Finance::Schedule::NPQEhco.schedule_for(cohort:)
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
