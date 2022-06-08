# frozen_string_literal: true

class SetSchoolLocalAuthority < BaseService
  def call
    if school.local_authority&.code != la_code
      ActiveRecord::Base.transaction do
        school.latest_school_authority&.update!(end_year: start_year)
        SchoolLocalAuthority.create!(school:,
                                     local_authority: LocalAuthority.find_by(code: la_code),
                                     start_year:)
      end
    end
  end

private

  attr_reader :la_code, :school, :start_year

  def initialize(school:, la_code:, start_year: Time.zone.now.year)
    @school = school
    @la_code = la_code
    @start_year = start_year
  end
end
