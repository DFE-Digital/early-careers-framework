# frozen_string_literal: true

ALL_URNS = (1..999_999).freeze unless defined?(ALL_URNS)

class SchoolURNGenerator
  class << self
    def next
      next_urn=next_from_available_stack
      add_to_taken_stack(next_urn)
      sprintf("%06d", next_urn)
    end

    private

    def add_to_taken_stack(next_urn)
      taken.push(next_urn)
    end

    def next_from_available_stack
      available.pop || (raise "URN available list exhausted")
    end

    def available
      @available.presence || reseed
    end

    def reseed
      @available = (1_000.times.map { rand(ALL_URNS) }.uniq - taken)
    end

    def taken
      @taken ||= School.where.not(urn: nil).pluck(:urn).map(&:to_i)
    end
  end
end
