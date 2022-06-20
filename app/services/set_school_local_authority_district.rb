# frozen_string_literal: true

class SetSchoolLocalAuthorityDistrict < BaseService
  def call
    if school.local_authority_district&.code != administrative_district_code
      ActiveRecord::Base.transaction do
        school.latest_school_authority_district&.update!(end_year: start_year)

        SchoolLocalAuthorityDistrict.create!(school:,
                                             local_authority_district: LocalAuthorityDistrict.find_by(code: administrative_district_code),
                                             start_year:)
      end
    end
  end

private

  attr_reader :administrative_district_code, :school, :start_year

  def initialize(school:, administrative_district_code: nil, start_year: Time.zone.now.year)
    @school = school
    @administrative_district_code = administrative_district_code || school.administrative_district_code
    @start_year = start_year
  end
end
