# frozen_string_literal: true

module DataStage
  class UpdateStagedSchools < ::BaseService
    include GiasTypes

    def initialize(school_data_file:, school_links_file:)
      @school_data_file = school_data_file
      @school_links_file = school_links_file
    end

    def call
      prep_caches
      update_schools
      update_school_links
    end

  private

    def prep_caches
      @la_cache = {}
      @lad_cache = {}

      LocalAuthority.all.each { |la| @la_cache[la.code] = la }
      LocalAuthorityDistrict.all.each { |lad| @lad_cache[lad.code] = lad }
    end

    def update_schools
      if @school_data_file
        CSV.foreach(@school_data_file, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
          if eligible_row? row
            setup_local_authority!(row)
            setup_local_authority_district!(row)

            school_attrs = filtered_attributes(row)
            urn = school_attrs.fetch(:urn)

            school = DataStage::School.find_by(urn: urn)

            if school.present?
              update_and_sync_changes!(school, school_attrs)
            else
              school = DataStage::School.create!(school_attrs)
              # NOTE: this will add any school to the live set that is "open" at the point
              # of being added to the data stage
              school.create_or_sync_counterpart! if school.open?
            end
          end
        end
      end
    end

    def update_and_sync_changes!(school, school_attributes)
      school.assign_attributes(school_attributes)
      return unless school.changed?

      simple_changes = school.changes.except(:updated_at, :la_code, *MAJOR_CHANGE_ATTRIBUTES)
      major_changes = school.changes.slice(*MAJOR_CHANGE_ATTRIBUTES)

      DataStage::School.transaction do
        school.save!
        if school.counterpart.present?
          school.counterpart.update!(extract_values_from(simple_changes)) if simple_changes.any?
          school.school_changes.create!(attribute_changes: major_changes, status: :changed) if major_changes.any?
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

    def setup_local_authority!(row)
      la_code = row.fetch("LA (code)")
      la_name = row.fetch("LA (name)")

      local_authority = @la_cache[la_code] || LocalAuthority.find_or_initialize_by(code: la_code)
      if local_authority.name != la_name
        if local_authority.persisted?
          Rails.logger.info "LA name changed in school import. Old name: #{local_authority.name}, New name: #{la_name}"
        end
        local_authority.name = la_name
        local_authority.save!
      end
      @la_cache[la_code] = local_authority
    end

    def setup_local_authority_district!(row)
      lad_code = row.fetch("DistrictAdministrative (code)")
      lad_name = row.fetch("DistrictAdministrative (name)")

      local_authority_district = @lad_cache[lad_code] || LocalAuthorityDistrict.find_or_initialize_by(code: lad_code)
      if local_authority_district.name != lad_name
        if local_authority_district.persisted?
          logger.info "LAD name changed in school import. Old name: #{local_authority_district.name}, New name: #{lad_name}"
        end
        local_authority_district.name = lad_name
        local_authority_district.save!
      end
      @lad_cache[lad_code] = local_authority_district
    end

    def eligible_row?(row)
      english_district_code?(row.fetch("DistrictAdministrative (code)")) &&
        eligible_establishment_code?(row.fetch("TypeOfEstablishment (code)").to_i)
    end

    def extract_values_from(changes_hash)
      changes_hash.transform_values(&:last)
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
        section_41_approved: data.fetch("Section41Approved (name)") == "Approved",
        la_code: data.fetch("LA (code)"),
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
