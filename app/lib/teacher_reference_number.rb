# frozen_string_literal: true

class TeacherReferenceNumber
  MIN_UNPADDED_TRN_LENGTH = 5
  PADDED_TRN_LENGTH = 7

  attr_reader :trn, :format_error

  def initialize(trn)
    @trn = trn
    @format_error = nil
  end

  def formatted_trn
    @formatted_trn ||= extract_trn_value
  end

  def valid?
    formatted_trn.present?
  end

private

  def extract_trn_value
    @format_error = :blank and return if trn.blank?

    # remove any characters that are not digits
    only_digits = trn.to_s.gsub(/[^\d]/, "")

    @format_error = :invalid and return if only_digits.blank?
    @format_error = :too_short and return if only_digits.length < MIN_UNPADDED_TRN_LENGTH
    @format_error = :too_long and return if only_digits.length > PADDED_TRN_LENGTH

    only_digits.rjust(PADDED_TRN_LENGTH, "0")
  end
end
