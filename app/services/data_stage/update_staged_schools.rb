# frozen_string_literal: true

module DataStage
  class UpdateStagedSchools < ::BaseService
    include GiasTypes

    def initialize(school_data_file:, school_links_file:)
      @school_data_file = school_data_file
      @school_links_file = school_links_file
    end

    def call
      update_schools
      update_school_links
    end

  private

    def update_schools
      if @school_data_file
        CSV.foreach(@school_data_file, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
          if eligible_row? row
            school_attrs = filtered_attributes(row)
            urn = school_attrs.fetch(:urn)

            school = DataStage::School.find_by(urn: urn)

            if school.present?
              school.update!(school_attrs)
            else
              DataStage::School.create!(school_attrs)
            end
          end
        end
      end
    end

    def update_school_links
      if @school_links_file
        CSV.foreach(@school_links_file, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
          link_attrs = link_attributes(row)

          school = DataStage::School.find_by(urn: link_attrs[:urn])

          if school.present?
            link = school.school_links.find_by(link_urn: link_attrs[:link_urn])

            if link.present?
              if link.link_type != link_attrs[:link_type]
                link.update!(link_type: link_attrs[:link_type])
              end
            else
              school.school_links.create!(link_attrs.except(:urn))
            end
          end
        end
      end
    end

    def eligible_row?(row)
      english_district_code?(row.fetch("DistrictAdministrative (code)")) &&
        eligible_establishment_code?(row.fetch("TypeOfEstablishment (code)").to_i)
    end

    def filtered_attributes(data)
      {
        urn: data.fetch("URN"),
        name: data.fetch("EstablishmentName"),
        ukprn: data.fetch("UKPRN").presence,
        school_phase_type: data.fetch("PhaseOfEducation (code)").to_i,
        school_phase_name: data.fetch("PhaseOfEducation (name)"),
        address_line1: data.fetch("Street"),
        address_line2: data.fetch("Locality").presence,
        address_line3: data.fetch("Town").presence,
        postcode: data.fetch("Postcode"),
        school_website: data.fetch("SchoolWebsite").presence,
        primary_contact_email: data.fetch("MainEmail").presence,
        secondary_contact_email: data.fetch("AlternativeEmail").presence,
        school_type_code: data.fetch("TypeOfEstablishment (code)").to_i,
        school_type_name: data.fetch("TypeOfEstablishment (name)"),
        school_status_code: data.fetch("EstablishmentStatus (code)").to_i,
        school_status_name: data.fetch("EstablishmentStatus (name)"),
        administrative_district_code: data.fetch("DistrictAdministrative (code)"),
        administrative_district_name: data.fetch("DistrictAdministrative (name)"),
      }
    end

    def link_attributes(data)
      {
        urn: data.fetch("URN"),
        link_urn: data.fetch("LinkURN"),
        link_type: data.fetch("LinkType"),
      }
    end
  end
end
