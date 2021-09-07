# frozen_string_literal: true

module GiasTypes
  extend ActiveSupport::Concern

  ELIGIBLE_TYPE_CODES = [1, 2, 3, 5, 6, 7, 8, 12, 14, 15, 18, 28, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48].freeze
  ELIGIBLE_STATUS_CODES = [1, 3].freeze
  CIP_ONLY_TYPE_CODES = [10, 11, 30, 37].freeze
  CIP_ONLY_EXCEPT_WELSH_CODES = [10, 11, 37].freeze

  def open_status_code?(status_code)
    ELIGIBLE_STATUS_CODES.include?(status_code)
  end

  def eligible_establishment_code?(establishment_type)
    ELIGIBLE_TYPE_CODES.include?(establishment_type)
  end

  def english_district_code?(district_code)
    district_code.to_s.match?(/^[Ee]/)
  end
end
