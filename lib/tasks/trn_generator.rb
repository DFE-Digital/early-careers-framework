# frozen_string_literal: true

ALL_TRNS = (1111..9_999_999).freeze unless defined?(ALL_TRNS)

class TRNGenerator
  class << self
    def next
      sprintf("%07d", taken.push(available.pop || (raise "TRN available list exhausted"))[-1])
    end

  private

    def available
      @available.presence || reseed
    end

    def reseed
      @available = (10_000.times.map { rand(ALL_TRNS) }.uniq - taken)
    end

    def taken
      @taken ||= TeacherProfile.where.not(trn: nil).pluck(:trn).map(&:to_i)
    end
  end
end
