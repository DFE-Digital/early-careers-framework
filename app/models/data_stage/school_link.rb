# frozen_string_literal: true

module DataStage
  class SchoolLink < ApplicationRecord
    self.table_name = "data_stage_school_links"

    validates :link_urn, presence: true, uniqueness: { scope: :data_stage_school_id }
    validates :link_type, presence: true

    belongs_to :data_stage_school, class_name: "DataStage::School", inverse_of: :school_links
  end
end
