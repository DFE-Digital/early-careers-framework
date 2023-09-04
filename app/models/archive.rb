# frozen_string_literal: true

class Archive < ApplicationRecord
  validates :object_type, presence: true
  validates :object_id, presence: true
  validates :reason, presence: true
  validates :data, presence: true

  scope :with_metadata_containing, ->(search_term) { where("data->'meta' @> :value", value: search_term.to_json) }
end
