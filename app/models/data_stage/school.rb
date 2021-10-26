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
      end
      handle_local_authority_changes!
    end

  private

    def attributes_to_sync
      attributes.except("id", "created_at", "updated_at", "la_code")
    end

    def handle_local_authority_changes!
      if counterpart.local_authority&.code != la_code
        SetSchoolLocalAuthority.call(school: counterpart,
                                     la_code: la_code)
      end

      if counterpart.administrative_district_code != counterpart.local_authority_district&.code
        SetSchoolLocalAuthorityDistrict.call(school: counterpart,
                                             administrative_district_code: administrative_district_code)
      end
    end
  end
end
