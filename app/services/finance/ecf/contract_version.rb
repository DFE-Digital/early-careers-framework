# frozen_string_literal: true

# Most contract versions are in the format "x.y.z", e.g. "0.0.1",
# however this is not always the case. Going forward we will attempt
# to increment the last digit of the version and retain the existing format.
# We will assume a version can be delimited by any non-number character.
#
# For example:
#
# 0.0.1   -> 0.0.2
# 1.2.3   -> 1.2.4
# 1.2     -> 1.3
# 1       -> 2
# 1-2-3   -> 1-2-4
# 1,2,3   -> 1,2,4
# 1--2--3 -> 1--2--4
#
# We assume that individual segments of a version cannot be greater than 999.
#

module Finance
  module ECF
    class ContractVersion
      class InvalidVersionError < StandardError; end
      class VersionOutOfRangeError < StandardError; end

      DIGITS_AND_NON_DIGITS_PATTERN = /(\d+|\D+)/
      MAXIMUM_DIGITS_PER_SEGMENT = 3

      def initialize(version_str)
        @segments = split_version_into_segments(version_str)

        raise InvalidVersionError, "Version: #{version_str}" if index_of_last_version.blank?
        raise VersionOutOfRangeError, "Version: #{version_str}" if numeric_segments_out_of_range?
      end

      def increment!
        segments[index_of_last_version] += 1
        to_s
      end

      # This is used to determine the order of contract versions. It convers
      # the delimited version string into a numerical value, such that
      # the higher left-most digits equate to a larger numerical value.
      #
      # For example:
      #
      # 1.234 -> 001234
      # 12.3  -> 012003
      def numerical_value
        segments
          .select { |s| s.is_a?(Numeric) }
          .map { |i| i.to_s.rjust(MAXIMUM_DIGITS_PER_SEGMENT, "0") }
          .join
          .to_i
      end

      def to_s
        segments.join
      end

    private

      attr_reader :segments

      def split_version_into_segments(version_str)
        version_str
          .scan(DIGITS_AND_NON_DIGITS_PATTERN)
          .map(&:first)
          .map { |match| Integer(match, exception: false) || match }
      end

      def numeric_segments_out_of_range?
        segments
          .select { |s| s.is_a?(Numeric) }
          .any? { |i| i.to_s.length > MAXIMUM_DIGITS_PER_SEGMENT }
      end

      def index_of_last_version
        segments.rindex { |segment| segment.is_a?(Numeric) }
      end
    end
  end
end
