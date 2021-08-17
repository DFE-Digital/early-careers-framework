# frozen_string_literal: true

ALL_URNS = (1..999_999).freeze unless defined?(ALL_URNS)

class SchoolURNGenerator
  class << self
    def next
      sprintf("%06d", taken.push(available.pop || (raise "URN available list exhausted"))[-1])
    end

  private

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
