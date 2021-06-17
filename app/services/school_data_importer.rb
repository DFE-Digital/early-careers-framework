# frozen_string_literal: true

require "gias_api_client"
require "csv"

class SchoolDataImporter
  attr_reader :logger
  attr_reader :start_year

  def initialize(logger, start_year = Time.zone.now.year)
    @logger = logger
    @start_year = start_year
  end

  def run
    files = school_data_files
    la_cache = {}
    lad_cache = {}

    CSV.foreach(files["ecf_tech.csv"].path, headers: true, encoding: "ISO-8859-1:UTF-8").each_slice(1000) do |rows|
      schools = School.where(urn: rows.map { |row| row.fetch("URN") }).index_by(&:urn)

      rows.each do |row|
        SchoolHandler.new(
          school: schools[row.fetch("URN")] || School.new(urn: row.fetch("URN")),
          data: row,
          logger: logger,
          start_year: start_year,
          la_cache: la_cache,
          lad_cache: lad_cache,
        ).call
      end
    end
  end

private

  def school_data_files
    @gias_api_client ||= GiasApiClient.new
    @gias_files ||= @gias_api_client.get_files
    @gias_files
  end

  class SchoolHandler
    attr_reader :school, :data, :logger, :start_year

    def initialize(school:, data:, logger:, start_year:, la_cache:, lad_cache:)
      @school = school
      @new_school = school.new_record?
      @logger = logger
      @data = data
      @start_year = start_year
      @la_cache = la_cache
      @lad_cache = lad_cache
    end

    def call
      ActiveRecord::Base.transaction do
        record_school_details
        return unless new_school?

        link_school_to_local_authority
        link_school_to_local_district_authority
      end
    end

  private

    def new_school?
      @new_school
    end

    def record_school_details
      school.name = data.fetch("EstablishmentName")
      school.address_line1 = data.fetch("Street")
      school.address_line2 = data.fetch("Locality")
      school.address_line3 = data.fetch("Town")
      school.postcode = data.fetch("Postcode")
      school.ukprn = data.fetch("UKPRN")
      school.school_phase_type = data.fetch("PhaseOfEducation (code)").to_i
      school.school_phase_name = data.fetch("PhaseOfEducation (name)")
      school.school_website = data.fetch("SchoolWebsite")
      school.primary_contact_email = data.fetch("MainEmail").presence
      school.secondary_contact_email = data.fetch("AlternativeEmail").presence

      # Changes to properties below carries major consequences and must be avoided until we know how to handle them
      if new_school?
        school.school_type_code = data.fetch("TypeOfEstablishment (code)").to_i
        school.school_type_name = data.fetch("TypeOfEstablishment (name)")

        school.school_status_code = data.fetch("EstablishmentStatus (code)").to_i
        school.school_status_name = data.fetch("EstablishmentStatus (name)")

        school.administrative_district_code = data.fetch("DistrictAdministrative (code)")
        school.administrative_district_name = data.fetch("DistrictAdministrative (name)")
      end

      school.save!
    end

    def local_authority
      return @local_authority if @local_authority

      code = data.fetch("LA (code)")
      @la_cache.fetch(code) do
        local_authority = LocalAuthority.find_or_initialize_by(code: code)
        new_name = data.fetch("LA (name)")

        if local_authority.name != new_name
          if local_authority.persisted?
            logger.info "LA name changed in school import. Old name: #{local_authority.name}, New name: #{new_name}"
          end
          local_authority.name = new_name
          local_authority.save!
        end

        @local_authority = @la_cache[code] = local_authority
      end
    end

    def local_district_authority
      return @local_district_authority if @local_district_authority

      code = data.fetch("DistrictAdministrative (code)")

      @lad_cache.fetch(code) do
        local_authority_district = LocalAuthorityDistrict.find_or_initialize_by(code: code)
        new_name = data.fetch("DistrictAdministrative (name)")

        if local_authority_district.name != new_name
          if local_authority_district.persisted?
            logger.info "LAD name changed in school import. Old name: #{local_authority_district.name}, New name: #{new_name}"
          end
          local_authority_district.name = new_name
          local_authority_district.save!
        end

        @local_district_authority = @lad_cache[code] = local_authority_district
      end
    end

    def link_school_to_local_authority
      SchoolLocalAuthority.create!(
        school: school,
        local_authority: local_authority,
        start_year: start_year,
      )
    end

    def link_school_to_local_district_authority
      SchoolLocalAuthorityDistrict.create!(
        school: school,
        local_authority_district: local_district_authority,
        start_year: start_year,
      )
    end
  end
end
