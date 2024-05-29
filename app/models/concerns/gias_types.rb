# frozen_string_literal: true

module GiasTypes
  extend ActiveSupport::Concern

  # Code 57 is a new addition for "Academy secure 16 to 19" - these are eligible for FIP funding
  ELIGIBLE_TYPE_CODES = [1, 2, 3, 5, 6, 7, 8, 12, 14, 15, 18, 28, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 57].freeze
  CIP_ONLY_TYPE_CODES = [10, 11, 30, 37].freeze
  CIP_ONLY_EXCEPT_WELSH_CODES = [10, 11, 37].freeze
  INDEPENDENT_SCHOOLS_TYPE_CODES = [10, 11].freeze

  # Types that *are* eligible but we would prefer not to send communications to.
  NO_INVITATIONS_TYPE_CODES = [47, 48].freeze

  OPEN_STATUS_CODES = [1, 3].freeze
  CLOSED_STATUS_CODES = [2, 4].freeze

  ALL_TYPE_CODES = (
    ELIGIBLE_TYPE_CODES +
    CIP_ONLY_TYPE_CODES +
    CIP_ONLY_EXCEPT_WELSH_CODES +
    INDEPENDENT_SCHOOLS_TYPE_CODES +
    NO_INVITATIONS_TYPE_CODES
  ).uniq.sort.freeze

  MAJOR_CHANGE_ATTRIBUTES = %w[
    school_status_code
    school_status_name
  ].freeze

  def open_status_code?(status_code)
    OPEN_STATUS_CODES.include?(status_code)
  end

  def eligible_establishment_code?(establishment_type)
    ELIGIBLE_TYPE_CODES.include?(establishment_type)
  end

  def cip_only_establishment_code?(establishment_type)
    CIP_ONLY_EXCEPT_WELSH_CODES.include?(establishment_type)
  end

  def english_district_code?(district_code)
    # expanded to include the 9999 code which seems to have crept in and is preventing a couple of schools onboarding
    # the establishment codes should filter out any that should not come in that are 9999 district
    district_code.to_s.match?(/^([Ee]|9999)/)
  end
end
