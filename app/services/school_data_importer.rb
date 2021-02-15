# frozen_string_literal: true

require "file_download"
require "csv"

class SchoolDataImporter
  attr_reader :logger
  attr_reader :start_year

  def initialize(logger, start_year = Time.zone.now.year)
    @logger = logger
    @start_year = start_year
  end

  # TODO: Register and Partner 147: Figure out how exactly we want to handle school updating
  def run
    CSV.foreach(schools_data_file.path, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
      school = row_to_school(row)
      local_authority = row_to_local_authority(row)
      local_authority_district = row_to_lad(row)

      link_school_to_local_authority(school, local_authority)
      link_school_to_lad(school, local_authority_district)
    end
  end

private

  def gias_schools_csv_url
    date_string = Time.zone.now.strftime("%Y%m%d")
    "#{Rails.application.config.gias_api_root}/edubase/downloads/public/edubasealldata#{date_string}.csv"
  end

  def schools_data_file
    FileDownload.new(gias_schools_csv_url).fetch
  end

  def row_to_school(row)
    school = School.find_or_initialize_by(urn: row.fetch("URN"))
    school.name = row.fetch("EstablishmentName")
    school.school_type_code = row.fetch("TypeOfEstablishment (code)")
    school.school_type_name = row.fetch("TypeOfEstablishment (name)")
    school.capacity = row.fetch("SchoolCapacity").to_i
    school.address_line1 = row.fetch("Street")
    school.address_line2 = row.fetch("Locality")
    school.address_line3 = row.fetch("Town")
    school.address_line4 = row.fetch("County (name)")
    school.country = row.fetch("Country (name)")
    school.postcode = row.fetch("Postcode")
    school.ukprn = row.fetch("UKPRN")
    school.previous_school_urn = row.fetch("PreviousEstablishmentNumber")
    school.school_phase_type = row.fetch("PhaseOfEducation (code)")
    school.school_phase_name = row.fetch("PhaseOfEducation (name)")
    school.school_website = row.fetch("SchoolWebsite")
    school.school_status_code = row.fetch("EstablishmentStatus (code)")
    school.school_status_name = row.fetch("EstablishmentStatus (name)")

    dummy_domain = Addressable::URI.parse(school.school_website)&.domain

    school.domains = [dummy_domain]
    school.primary_contact_email = "main.email@#{dummy_domain}"
    school.secondary_contact_email = "secondary.email@#{dummy_domain}"
    school.save!
    school
  end

  def row_to_local_authority(row)
    local_authority = LocalAuthority.find_or_initialize_by(code: row.fetch("LA (code)"))
    row_local_authority_name = row.fetch("LA (name)")

    if local_authority.persisted? && local_authority.name != row_local_authority_name
      logger.info "LA name change in school import. Old name: #{local_authority.name}, New name: #{row_local_authority_name}"
    end

    local_authority.name = row_local_authority_name
    local_authority.save!
    local_authority
  end

  def row_to_lad(row)
    local_authority_district = LocalAuthorityDistrict.find_or_initialize_by(code: row.fetch("DistrictAdministrative (code)"))
    row_lad_name = row.fetch("DistrictAdministrative (name)")

    if local_authority_district.persisted? && local_authority_district.name != row_lad_name
      logger.info "LA name change in school import. Old name: #{local_authority_district.name}, New name: #{row_lad_name}"
    end

    local_authority_district.name = row_lad_name
    local_authority_district.save!
    local_authority_district
  end

  def link_school_to_local_authority(school, local_authority)
    school_local_authority = SchoolLocalAuthority.find_or_initialize_by(school: school, local_authority: local_authority)

    if school_local_authority.new_record?
      school_local_authority.start_year = start_year
      SchoolLocalAuthority.latest.find_by(school: school)&.update!(end_year: start_year)
    end

    school_local_authority.save!
  end

  def link_school_to_lad(school, lad)
    school_lad = SchoolLocalAuthorityDistrict.find_or_initialize_by(
      school: school,
      local_authority_district: lad,
    )

    if school_lad.new_record?
      school_lad.start_year = start_year
      SchoolLocalAuthorityDistrict.latest.find_by(school: school)&.update!(end_year: start_year)
    end

    school_lad.save!
  end
end
