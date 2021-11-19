# frozen_string_literal: true

class SchoolLink < ApplicationRecord
  belongs_to :school
  has_one :link_school, class_name: "School",
                        foreign_key: :urn,
                        primary_key: :link_urn

  enum link_type: {
    predecessor: "predecessor",
    successor: "successor",
  }

  enum link_reason: {
    simple: "simple",
    school_merger: "school_merger",
    school_split: "school_split",
    other: "other",
  }
end
