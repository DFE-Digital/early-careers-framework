# frozen_string_literal: true

class SetSchoolLocalAuthority < BaseService
  def call
    if school.local_authority&.code != la_code
      ActiveRecord::Base.transaction do
        school.latest_school_authority&.update!(end_year: start_year)
        SchoolLocalAuthority.create!(school: school,
                                     local_authority: LocalAuthority.find_by(code: la_code),
                                     start_year: start_year)
        update_pupil_premiums!
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

  def update_pupil_premiums!
    # pupil premiums are added via an import process so if this school
    # is new it may not have had any associated with it yet
    unless school.partnerships.any?
      uplift = school.pupil_premium_uplift?(start_year)

      school.school_cohorts.for_year(start_year).first&.ecf_participant_profiles&.each do |profile|
        profile.update!(pupil_premium_uplift: uplift)
      end
    end
  end
end
