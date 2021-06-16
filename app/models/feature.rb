# frozen_string_literal: true

class Feature < ApplicationRecord
  has_many :selected_objects

  class SelectedObject < ApplicationRecord
    self.table_name = "feature_selected_objects"
    belongs_to :object, polymorphic: true
  end
end
