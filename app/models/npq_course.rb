# frozen_string_literal: true

class NPQCourse < ApplicationRecord
  has_many :npq_applications

  class << self
    def identifiers
      pluck(:identifier)
    end

    def schedule_for(npq_course)
      case npq_course.identifier
      when *Finance::Schedule::NPQLeadership::IDENTIFIERS
        Finance::Schedule::NPQLeadership.default
      when *Finance::Schedule::NPQSpecialist::IDENTIFIERS
        Finance::Schedule::NPQSpecialist.default
      when "npq-additional-support-offer"
        # TODO: Figure out what ASO schedules look like
        Finance::Schedule::NPQSpecialist.default
      else
        raise ArgumentError, "Invalid course identifier"
      end
    end
  end
end
