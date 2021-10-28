# frozen_string_literal: true

class NPQCourse < ApplicationRecord
  has_many :npq_applications

  LEADERSHIP_IDENTIFIER = %w[
    npq-leading-teaching
    npq-leading-behaviour-culture
    npq-leading-teaching-development
  ].freeze

  SPECIALIST_IDENTIFIER = %w[
    npq-senior-leadership
    npq-headship
    npq-executive-leadership
  ].freeze

  class << self
    def identifiers
      pluck(:identifier)
    end

    def schedule_for(npq_course)
      case npq_course.identifier
      when *NPQCourse::LEADERSHIP_IDENTIFIER
        Finance::Schedule::NPQLeadership.default
      when *NPQCourse::SPECIALIST_IDENTIFIER
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
