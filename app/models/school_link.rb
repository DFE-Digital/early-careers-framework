# frozen_string_literal: true

class SchoolLink < ApplicationRecord
  belongs_to :school
  belongs_to :link_school, class_name: "School"

  enum link_type: {
    predecessor: "predecessor",
    successor: "successor",
  }

  enum link_reason: {
    simple: "simple",
    merger: "merger",
    split: "split",
    other: "other",
  }
end
