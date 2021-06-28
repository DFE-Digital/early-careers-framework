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

    after_create :log_create
    before_update :log_changes

    scope :schools_to_add, -> { currently_open.joins("LEFT JOIN schools s ON (data_stage_schools.urn = s.urn)").where("s.urn IS NULL") }

    scope :schools_to_close, -> { closed_status.joins("LEFT JOIN schools s ON (data_stage_schools.urn = s.urn)").where("s.school_status_code IN (?)", ELIGIBLE_STATUS_CODES) }

  private

    def log_create
      school_changes.create!(status: :added)
    end

    def log_changes
      school_changes.create!(attribute_changes: changes, status: :changed) if changes.any?
    end
  end
end
