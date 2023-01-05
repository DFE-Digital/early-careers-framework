# frozen_string_literal: true

class NPQCourse < ApplicationRecord
  has_many :npq_applications

  def self.identifiers
    pluck(:identifier)
  end

  def self.schedule_for(npq_course:, cohort: Cohort.find_by!(start_year: 2021))
    case npq_course.identifier
    when *Finance::Schedule::NPQLeadership::IDENTIFIERS
      Finance::Schedule::NPQLeadership.find_by!(cohort:)
    when *Finance::Schedule::NPQSpecialist::IDENTIFIERS
      Finance::Schedule::NPQSpecialist.find_by!(cohort:)
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
