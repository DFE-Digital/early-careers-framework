# frozen_string_literal: true

class NPQCourse < ApplicationRecord
  has_many :npq_applications

  SPECIALIST_IDENTIFIER = %w[
    npq-leading-teaching
    npq-leading-behaviour-culture
    npq-leading-teaching-development
  ].freeze

  LEADERSHIP_IDENTIFIER = %w[
    npq-senior-leadership
    npq-headship
    npq-executive-leadership
  ].freeze

  class << self
    def identifiers
      pluck(:identifier)
    end
  end
end
