# frozen_string_literal: true

class SetSchoolLocalAuthorityDistrict < BaseService
  def call
    if school.local_authority_district&.code != administrative_district_code
      ActiveRecord::Base.transaction do
        school.school_local_authority_districts.latest.first&.update!(end_year: start_year)

        SchoolLocalAuthorityDistrict.create!(school: school,
                                             local_authority_district: la_district,
                                             start_year: start_year)
        update_participants_sparsity_flag!
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

  def update_participants_sparsity_flag!
    unless school.partnerships.any?
      lad_sparsity = la_district.sparse?(start_year)
      school.school_cohorts.for_year(start_year).first&.ecf_participant_profiles&.each do |profile|
        profile.update!(sparsity_uplift: lad_sparsity)
      end
    end
  end

  def la_district
    @la_district ||= LocalAuthorityDistrict.find_by(code: administrative_district_code)
  end
end
