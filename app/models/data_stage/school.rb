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

    scope :schools_to_add, -> { currently_open.left_joins(:counterpart).where(counterpart: { urn: nil }) }

    scope :schools_to_open, -> { currently_open.joins(:counterpart).where(counterpart: { school_status_name: :proposed_to_open }) }

    scope :schools_to_close, -> { closed_status.left_joins(:counterpart).where(counterpart: { school_status_code: GiasTypes::ELIGIBLE_STATUS_CODES }) }

    scope :schools_with_changes, -> { includes(:school_changes).where(school_changes: { status: :changed, handled: false }) }

    def create_counterpart_school!
      return if ::School.exists?(urn: urn)

      create_counterpart!(attributes.except("id", "created_at", "updated_at"))
      # ::School.create!(attributes.except("id", "created_at", "updated_at"))
    end

    def update_and_sync_changes!(school_attributes)
      special_case_attributes = %i[
        administrative_district_code
        administratuve_district_name
        school_status_code
        school_status_name
        school_type_code
        school_type_name
        section_41_approved
        ukprn
      ].freeze

      assign_attributes(school_attributes)
      simple_changes = changes.except(:updated_at, *special_case_attributes)
      major_changes = changes.slice(*special_case_attributes)

      DataStage::School.transaction do
        save!
        if counterpart.present?
          counterpart.update!(simple_changes) if simple_changes.any?
          school_changes.create!(attribute_changes: major_changes, status: :changed) if major_changes.any?
        end
      end
    end

  private

    def log_create
      school_changes.create!(status: :added)
    end

    # def log_changes
    #   relevant_changes = changes.except(:updated_at, :school_status_code, :school_status_name)
    #
    #   school_changes.create!(attribute_changes: relevant_changes, status: :changed) if relevant_changes.any?
    # end
  end
end
