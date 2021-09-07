# frozen_string_literal: true

module DataStage
  class School < ApplicationRecord
    include GiasHelpers

    self.table_name = "data_stage_schools"

    has_many :school_changes, class_name: "DataStage::SchoolChange",
                              foreign_key: :data_stage_school_id,
                              dependent: :destroy

    has_many :school_links, class_name: "DataStage::SchoolLink",
                            foreign_key: :data_stage_school_id,
                            dependent: :destroy

    has_one :counterpart, class_name: "::School",
                          foreign_key: :urn,
                          primary_key: :urn

    scope :schools_to_add, -> { currently_open.left_joins(:counterpart).where(counterpart: { urn: nil }) }

    scope :schools_to_open, -> { currently_open.joins(:counterpart).where(counterpart: { school_status_name: :proposed_to_open }) }

    scope :schools_to_close, -> { closed_status.left_joins(:counterpart).where(counterpart: { school_status_code: GiasTypes::ELIGIBLE_STATUS_CODES }) }

    scope :schools_with_changes, -> { includes(:school_changes).where(school_changes: { status: :changed, handled: false }) }

    def create_or_sync_counterpart!
      if counterpart.present?
        counterpart.update!(attributes_to_sync)
      else
        create_counterpart!(attributes_to_sync)
        link_counterpart_to_local_authority_data
      end
    end

  private

    def attributes_to_sync
      attributes.except("id", "created_at", "updated_at", "la_code")
    end

    def link_counterpart_to_local_authority_data(start_year: Time.zone.now.year)
      SchoolLocalAuthority.create!(
        school: counterpart,
        local_authority: LocalAuthority.find_by(code: la_code),
        start_year: start_year,
      )

      SchoolLocalAuthorityDistrict.create!(
        school: counterpart,
        local_authority_district: LocalAuthorityDistrict.find_by(code: administrative_district_code),
        start_year: start_year,
      )
    end

    # def log_create
    #   school_changes.create!(status: :added)
    # end
    #
    # def log_changes
    #   relevant_changes = changes.except(:updated_at, :school_status_code, :school_status_name)
    #
    #   school_changes.create!(attribute_changes: relevant_changes, status: :changed) if relevant_changes.any?
    # end
  end
end
