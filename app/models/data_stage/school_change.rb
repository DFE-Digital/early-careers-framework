# frozen_string_literal: true

module DataStage
  class SchoolChange < ApplicationRecord
    self.table_name = "data_stage_school_changes"

    belongs_to :school, class_name: "DataStage::School",
                        foreign_key: :data_stage_school_id

    scope :unhandled, -> { where(handled: false) }

    enum status: {
      added: "added",
      changed: "changed",
      closed: "closed",
    }, _prefix: true
  end
end
