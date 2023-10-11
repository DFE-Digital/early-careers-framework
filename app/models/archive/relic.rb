# frozen_string_literal: true

module Archive
  class Relic < ApplicationRecord
    validates :object_type, presence: true
    validates :object_id, presence: true
    validates :reason, presence: true
    validates :display_name, presence: true
    validates :data, presence: true

    scope :with_metadata_containing, ->(search_term) { where("data->>'meta' ilike :value", value: "%#{search_term}%") }
  end
end
